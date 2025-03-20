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
var gemstone_scene: PackedScene
var tic_scene: PackedScene
var tac_scene: PackedScene
var toe_scene: PackedScene
var fire_bubble_scene: PackedScene
var jack_in_the_box_scene: PackedScene
var enemy_respawn_anim: PackedScene
var xob_scene: PackedScene

var cards_amount := 3

var current_balloon: Balloons.BALLOON_TYPE
var balloon: Balloons
var is_balloon_spawned := false

const pop_balloon_delay := 3.0

var pop_balloon_timer := Timer.new()

var current_treat: Treats.TREAT_TYPE = 0

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

const bonus_round_duration := 20.0
var bonus_round_timer := Timer.new()

var bonus_round := false

var gemstones: Array[Gemstone]

var xob: Xob

const respawn_delay := 3
var respawn_delay_timer := Timer.new()

signal restart
signal next_level

signal balloon_popped


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
			i.shoot_fire_bubble.connect(_on_shoot_fire_bubble)
			i.put_jack_in_the_box.connect(_on_jack_in_the_box_putted)
			aoy = i
		if i is Enemy:
			i.map_offset = map_offset
			i.defeated.connect(_on_enemy_defeated)
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
	
	add_child(bonus_round_timer)
	bonus_round_timer.timeout.connect(_on_bonus_round_time_end)
	
	add_child(pop_balloon_timer)
	pop_balloon_timer.timeout.connect(_on_pop_balloon_time_end)
	
	respawn_delay_timer.one_shot = true
	
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
	obj.popped.connect(_on_balloon_popped)
	add_child(obj)
	
	balloon = obj
	
	pop_balloon_timer.start(pop_balloon_delay)

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

func spawn_gemstones() -> void:
	var segment := 0
	
	for x in range(map_size.position.x, map_size.size.x):
		for y in range(map_size.position.y, map_size.size.y):
			var obj_pos: Vector2i = Vector2i(x, y)
			
			if tiles.get_cell_atlas_coords(obj_pos - Vector2i.ONE) == Vector2i(1, 0) \
			and segment == 0:
				var obj: Gemstone = gemstone_scene.instantiate()
				obj.picked.connect(_on_gemstone_picked)
				add_child(obj)
				gemstones.append(obj)
			
			if segment < 3: segment += 1
			else: segment = 0

func spawn_fire_bubble(pos: Vector2, direction: FireBubble.DIRECTION) -> void:
	var obj: FireBubble = fire_bubble_scene.instantiate()
	obj.direction = direction
	obj.position = pos
	add_child(obj)

func spawn_jack_in_the_box(pos: Vector2) -> void:
	var obj: JackInTheBox = jack_in_the_box_scene.instantiate()
	obj.position = pos
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

func respawn_enemy(type: Enemy.TYPE) -> void:
	var anim: AnimatedSprite2D = enemy_respawn_anim.instantiate()
	anim.position = pick_random_pos()
	
	respawn_delay_timer.start(respawn_delay)
	await respawn_delay_timer.timeout
	
	var obj: Enemy
	
	match type:
		Enemy.TYPE.Tic:
			obj = tic_scene.instantiate()
		Enemy.TYPE.Tac:
			obj = tac_scene.instantiate()
		Enemy.TYPE.Toe:
			obj = toe_scene.instantiate()
	
	obj.map_offset = map_offset
	obj.defeated.connect(_on_enemy_defeated)
	obj.position = anim.position
	
	add_child(obj)
	enemies.append(obj)
	
	anim.queue_free()


func _on_aoy_change_pos(pos: Vector2) -> void:
	for i in enemies:
		if i != null: i.set_targer_pos(pos)
	
	if xob != null:
		xob.set_targer_pos(pos)


func _on_card_picked() -> void:
	if current_balloon != Balloons.BALLOON_TYPE.Nothing:
		if not is_balloon_spawned:
			spawn_balloon()
			is_balloon_spawned = true
		else:
			spawn_power_up()
	
	else:
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

func _on_pop_balloon_time_end() -> void:
	balloon.pop_animation()

func _on_balloon_popped() -> void:
	bonus_round = true
	bonus_round_timer.start(bonus_round_duration)
	balloon_popped.emit()
	spawn_gemstones()

func _on_gemstone_picked() -> void:
	add_score(300)

func _on_bonus_round_time_end() -> void:
	bonus_round = false
	remove_gemstones()

func _on_shoot_fire_bubble(pos: Vector2, direction: FireBubble.DIRECTION) -> void:
	spawn_fire_bubble(pos, direction)

func _on_jack_in_the_box_putted(pos: Vector2) -> void:
	spawn_jack_in_the_box(pos)

func _on_enemy_defeated(type: Enemy.TYPE) -> void:
	respawn_enemy(type)

func _on_indoor() -> void:
	get_tree().paused = true
	next_level.emit(next_scene)


func remove_gemstones() -> void:
	for i in gemstones:
		i.queue_free()
	
	gemstones.clear()


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
