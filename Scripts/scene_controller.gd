class_name SceneController extends Node2D

enum XobSpawnSide { Top, Bottom, Left, Right }

var map_offset: Vector2

@export_category("Map Characteristics")
# Map size in tiles. You can see it just select the "Walls" node, then
# moving cursor to the tile at the left-top corner, then to
# the right-bottom corner.
@export var map_size: Rect2i

@export var toys_textures: Array[Texture2D]

@export_category("Scenes")
@export var next_scene: PackedScene

var game_ui: GameUI
var tiles: TileMapLayer
var aoy: Aoy
var enemies: Array[Enemy]
var toy_chest: ToyChest

var balloon_scene: PackedScene
var treat_scene: PackedScene
var card_scene: PackedScene
var toy_scene: PackedScene
var key_scene: PackedScene
var door_scene: PackedScene
var power_up_scene: PackedScene
var xob_scene: PackedScene

var cards_amount := 3

var current_balloon: Balloons.BALLOON_TYPE = 0
var current_treat: Treats.TREAT_TYPE = 0

var balloon: Balloons

# The spawn delay for treats and balloons in seconds
const treats_spawn_delay := 5.0

var treats_spawn_timer := Timer.new()
var treat: Treats
var is_treat_picked := false

var door: Door

var score := 0

var toys_left := 0

var bonus_time := 10000
var bonus_time_timer := Timer.new()

var xob: Xob

signal restart
signal next_level


func _ready() -> void:
	for i in get_children():
		if i is GameUI:
			game_ui = i
		if i is TileMapLayer:
			tiles = i
		if i is Aoy:
			i.map_offset = map_offset
			i.change_pos.connect(_on_aoy_change_pos)
			i.restart.connect(func(): restart.emit())
			aoy = i
		if i is Enemy:
			i.map_offset = map_offset
			enemies.append(i)
		if i is ToyChest:
			i.toy_dropped.connect(_on_toy_dropped)
			toy_chest = i
		if i is Door:
			i.indoor.connect(_on_indoor)
			door = i
	
	if tiles != null:
		map_offset = tiles.position
		tiles.hide()
	
	for i in range(cards_amount):
		spawn_card()
	
	for i in toys_textures:
		spawn_toy(i)
	
	add_child(treats_spawn_timer)
	treats_spawn_timer.timeout.connect(spawn_treat)
	treats_spawn_timer.start(treats_spawn_delay)
	
	add_child(bonus_time_timer)
	bonus_time_timer.timeout.connect(_on_bonus_time_tick)
	bonus_time_timer.start(0.1)
	
	game_ui.show()
	game_ui.set_score(0)


func pick_random_pos() -> Vector2:
	var obj_pos: Vector2i
	
	while true:
		obj_pos = Vector2i(randi_range(map_size.position.x + 1, map_size.size.x - 2), \
		randi_range(map_size.position.y + 1, map_size.size.y - 2))
		
		if tiles.get_cell_atlas_coords(obj_pos - Vector2i.ONE) == Vector2i(1, 0) \
		and obj_pos.distance_to(aoy.global_position / 16) > 2.0 \
		and obj_pos.distance_to(toy_chest.global_position / 16) > 2.0:
			break
	
	obj_pos *= 16
	
	return obj_pos


func spawn_toy(texture: Texture2D) -> void:
	var obj: Toy = toy_scene.instantiate()
	obj.position = pick_random_pos()
	add_child(obj)
	obj.set_sprite(texture)
	toys_left += 1

func spawn_card() -> void:
	var obj: Cards = card_scene.instantiate()
	obj.picked.connect(_on_card_picked)
	obj.position = pick_random_pos()
	add_child(obj)

func spawn_balloon() -> void:
	var obj: Balloons = balloon_scene.instantiate()
	obj.balloon_type = current_balloon
	obj.position = pick_random_pos()
	add_child(obj)
	
	balloon = obj

func spawn_treat() -> void:
	if not is_treat_picked:
		current_treat = 0
	is_treat_picked = false
	
	if treat != null: treat.queue_free()
	
	var obj: Treats = treat_scene.instantiate()
	obj.treat_type = current_treat
	obj.picked.connect(_on_treat_picked)
	obj.position = pick_random_pos()
	add_child(obj)
	
	treat = obj

func spawn_key() -> void:
	var obj: Key = key_scene.instantiate()
	obj.picked.connect(_on_key_picked)
	obj.position = pick_random_pos()
	add_child(obj)

func spawn_power_up() -> void:
	var obj: PowerUp = power_up_scene.instantiate()
	obj.power_up_type = randi() % PowerUp.POWER_UP_TYPE.size()
	obj.position = pick_random_pos()
	add_child(obj)

func spawn_xob() -> void:
	var obj: Xob = xob_scene.instantiate()
	var side: XobSpawnSide = randi() % XobSpawnSide.size()
	
	match side:
		XobSpawnSide.Top:
			obj.position = Vector2(randf_range(map_size.position.x * 16, map_size.size.x * 16), map_size.position.y * 16)
		XobSpawnSide.Bottom:
			obj.position = Vector2(randf_range(map_size.position.x * 16, map_size.size.x * 16), map_size.size.y * 16)
		XobSpawnSide.Left:
			obj.position = Vector2(map_size.position.x * 16, randf_range(map_size.position.y * 16, map_size.size.y * 16))
		XobSpawnSide.Right:
			obj.position = Vector2(map_size.size.x * 16, randf_range(map_size.position.y * 16, map_size.size.y * 16))
	
	obj.position += map_offset
	
	add_child(obj)
	
	xob = obj


func _on_aoy_change_pos(pos: Vector2) -> void:
	for i in enemies:
		i.set_targer_pos(pos)
	
	if xob != null:
		xob.set_targer_pos(pos)


func _on_card_picked() -> void:
	spawn_power_up()

func _on_treat_picked() -> void:
	match current_treat:
		Treats.TREAT_TYPE.Candy:
			add_score(500)
		Treats.TREAT_TYPE.CandyCane:
			add_score(1000)
		Treats.TREAT_TYPE.ChocolateBar:
			add_score(2000)
		Treats.TREAT_TYPE.IceCream:
			add_score(3000)
		Treats.TREAT_TYPE.Cake:
			add_score(5000)
	
	if current_treat < Treats.TREAT_TYPE.size() - 1:
		current_treat += 1
	else:
		current_treat = 0
	
	is_treat_picked = true

func _on_key_picked() -> void:
	door.open_door()

func _on_toy_dropped() -> void:
	add_score(100)
	if toys_left > 1:
		toys_left -= 1
	else:
		spawn_key()

func _on_indoor() -> void:
	get_tree().paused = true
	next_level.emit(next_scene)


func add_score(points: int) -> void:
	score += points
	game_ui.set_score(score)

func set_lives(amount: int) -> void:
	game_ui.set_lives(amount)


func _on_bonus_time_tick() -> void:
	if bonus_time > 0:
		bonus_time -= 10
	else:
		if xob == null: spawn_xob()
	
	game_ui.set_bonus_time(bonus_time)
