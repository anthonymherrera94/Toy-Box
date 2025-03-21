class_name SceneController extends Node2D

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

var cards_amount := 5

var balloon: Balloons
var is_balloon_spawned := false

const pop_balloon_delay := 5.0
var pop_balloon_timer := Timer.new()

var current_treat: Treats.TYPE = 0

var treat: Treats
var is_treat_picked := false

var door: Door

var score := 0

var toys_left := 0

var bonus_time := 10000

var bonus_round := false

var gemstones: Array[Gemstone]

var xob: Xob

signal spawn_toy
signal spawn_card
signal spawn_balloon
signal spawn_power_up
signal spawn_key
signal spawn_gemstones
signal spawn_xob

signal spawn_fire_bubble
signal spawn_jack_in_the_box

signal respawn_enemy

signal lose_live
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
			i.lose_live.connect(func(): lose_live.emit())
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
		spawn_card.emit()
	
	for i in toys_textures:
		spawn_toy.emit(i)
	
	add_child(pop_balloon_timer)
	pop_balloon_timer.timeout.connect(_on_pop_balloon_time_end)
	
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


func _on_aoy_change_pos(pos: Vector2) -> void:
	for i in enemies:
		if i != null: i.set_targer_pos(pos)
	
	if xob != null:
		xob.set_targer_pos(pos)


func _on_card_picked() -> void:
	if not is_balloon_spawned:
		spawn_balloon.emit()
		is_balloon_spawned = true
	else:
		spawn_power_up.emit()

func _on_treat_picked() -> void:
	match current_treat:
		Treats.TYPE.Candy:
			add_score(500)
		Treats.TYPE.CandyCane:
			add_score(1000)
		Treats.TYPE.ChocolateBar:
			add_score(2000)
		Treats.TYPE.IceCream:
			add_score(3000)
		Treats.TYPE.Cake:
			add_score(5000)
	
	if current_treat < Treats.TYPE.size() - 1:
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
		spawn_key.emit()

func _on_pop_balloon_time_end() -> void:
	if balloon != null: balloon.pop_animation()

func _on_balloon_popped(type: Balloons.TYPE) -> void:
	bonus_round = true
	game_ui.pop_balloon(type)
	balloon_popped.emit(type)
	spawn_gemstones.emit()

func _on_gemstone_picked() -> void:
	add_score(300)

func _on_bonus_round_time_end() -> void:
	bonus_round = false
	remove_gemstones()

func _on_shoot_fire_bubble(pos: Vector2, direction: FireBubble.DIRECTION) -> void:
	spawn_fire_bubble.emit(pos, direction)

func _on_jack_in_the_box_putted(pos: Vector2) -> void:
	spawn_jack_in_the_box.emit(pos)

func _on_enemy_defeated(type: Enemy.TYPE) -> void:
	respawn_enemy.emit(type)

func _on_indoor() -> void:
	get_tree().paused = true
	next_level.emit(next_scene)


func remove_gemstones() -> void:
	for i in gemstones:
		if i != null: i.queue_free()
	
	gemstones.clear()


func add_score(points: int) -> void:
	score += points
	game_ui.set_score(score)

func set_lives(amount: int) -> void:
	game_ui.set_lives(amount)

func set_popped_balloon(type: Balloons.TYPE) -> void:
	game_ui.pop_balloon(type)


func _on_bonus_time_tick() -> void:
	if bonus_time > 0:
		bonus_time -= 10
	else:
		if xob == null: spawn_xob.emit()
	
	game_ui.set_bonus_time(bonus_time)
