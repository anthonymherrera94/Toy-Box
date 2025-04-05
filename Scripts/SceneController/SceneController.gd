class_name SceneController extends Node

var map_offset: Vector2

@export_category("Scene Controllers")
@export var spawning: SceneControllerSpawning
@export var objects_holder: SceneControllerObjectsHolder
@export var game_stats: GameStats

@export_category("Map Characteristics")
# Map size in tiles. You can see it just select the "Walls" node, then
# moving cursor to the tile at the left-top corner, then to
# the right-bottom corner.
@export var map_size: Rect2i

@export_category("Game Options")
@export var toys_textures: Array[Texture2D]
@export var cards_amount: int

@export_category("Scenes")
@export var next_scene: PackedScene

var tiles: TileMapLayer

var bonus_round := false

signal restart
signal next_level

signal treat_picked
signal balloon_popped

var treats_picked_delay: Timer
var ballon_pop_delay: Timer
var bonus_round_timer: Timer
var respawn_delay_timer: Timer


func _ready() -> void:
	for i in get_parent().get_children():
		if i is GameUI:
			game_stats.game_ui = i
			game_stats.initialize()
		if i is TileMapLayer:
			tiles = i
	
	if tiles != null:
		map_offset = tiles.position
		tiles.hide()
	
	_initialize()
	
	for i in get_parent().get_children():
		if i is Aoy:
			i.map_offset = map_offset
			i.change_pos.connect(_on_aoy_change_pos)
			i.earn_score.connect(_on_earn_score)
			i.power_up_picked.connect(_on_power_up_picked)
			i.lose_live.connect(game_stats._on_lose_live)
			i.shoot_fire_bubble.connect(_on_shoot_fire_bubble)
			i.put_jack_in_the_box.connect(_on_jack_in_the_box_putted)
			objects_holder.aoy = i
		if i.get_child(0) is Enemy:
			i.get_child(0).map_offset = map_offset
			i.get_child(0).defeated.connect(_on_enemy_defeated)
			objects_holder.enemies.append(i)
		if i is ToyChest:
			i.toy_dropped.connect(_on_toy_dropped)
			objects_holder.toy_chest = i
		if i is Door:
			i.indoor.connect(_on_indoor)
			objects_holder.door = i
	
	for i in range(cards_amount):
		spawning.spawn_card()
	
	for i in toys_textures:
		spawning.spawn_toy(i)
	
	ballon_pop_delay.timeout.connect(_on_balloon_pop_time_end)
	treats_picked_delay.timeout.connect(_on_treats_picked_time_end)

func _initialize() -> void:
	spawning.main = self
	spawning.objects_holder = objects_holder
	spawning.game_stats = game_stats
	spawning.map_offset = map_offset
	spawning.map_size = map_size
	
	objects_holder.main = self
	
	game_stats.main = self
	game_stats.spawning = spawning
	game_stats.objects_holder = objects_holder


func _on_aoy_change_pos(pos: Vector2) -> void:
	if objects_holder.xob != null:
		objects_holder.xob.set_targer_pos(pos)

func _on_earn_score(_score: int) -> void:
	game_stats.add_score(_score)

func _on_power_up_picked() -> void:
	game_stats.power_up_score = 400


func _on_shoot_fire_bubble(pos: Vector2, direction: FireBubble.DIRECTION) -> void:
	spawning.spawn_fire_bubble(pos, direction)

func _on_jack_in_the_box_putted(pos: Vector2) -> void:
	spawning.spawn_jack_in_the_box(pos)


func _on_enemy_defeated(type: Enemy.TYPE, spawn_pos: Vector2) -> void:
	game_stats.earn_score_from_enemy()
	spawning.respawn_enemy(type, spawn_pos)


func _on_indoor() -> void:
	objects_holder.aoy.victory(objects_holder.door.global_position)
	next_level.emit(next_scene)


func _on_treats_picked_time_end() -> void:
	if objects_holder.treat != null: objects_holder.treat.queue_free()

func _on_balloon_pop_time_end() -> void:
	if objects_holder.balloon != null: objects_holder.balloon.pop_animation()

func _on_bonus_round_time_end() -> void:
	bonus_round = false
	remove_gemstones()


func remove_gemstones() -> void:
	for i in objects_holder.gemstones:
		if i != null: i.queue_free()
	
	objects_holder.gemstones.clear()


func _on_balloon_popped(type: Balloons.TYPE) -> void:
	bonus_round = true
	game_stats.game_ui.pop_balloon(type)
	balloon_popped.emit(type)
	
	if type >= Balloons.TYPE.size() - 1: spawning.spawn_gemstones()

func _on_gemstone_picked() -> void:
	game_stats.add_score(300)

func _on_card_picked(object_into: Cards.ObjectsInto, pos: Vector2) -> void:
	match object_into:
		Cards.ObjectsInto.Ballooon:
			spawning.spawn_balloon()
		Cards.ObjectsInto.BubbleGun:
			spawning.spawn_power_up(PowerUp.TYPE.BubbleGun)
		Cards.ObjectsInto.JackInTheBox:
			spawning.spawn_power_up(PowerUp.TYPE.JackInTheBox)
		Cards.ObjectsInto.RollerSkate:
			spawning.spawn_power_up(PowerUp.TYPE.RollerSkate)
		Cards.ObjectsInto.ToyHammer:
			spawning.spawn_power_up(PowerUp.TYPE.ToyHammer)
		Cards.ObjectsInto.Bomb:
			spawning.spawn_bomb(pos)

func _on_treat_picked() -> void:
	match game_stats.current_treat:
		Treats.TYPE.Candy:
			game_stats.add_score(500)
		Treats.TYPE.CandyCane:
			game_stats.add_score(1000)
		Treats.TYPE.ChocolateBar:
			game_stats.add_score(2000)
		Treats.TYPE.IceCream:
			game_stats.add_score(3000)
		Treats.TYPE.Cake:
			game_stats.add_score(5000)
	
	treat_picked.emit()

func _on_key_picked() -> void:
	objects_holder.door.open_door()

func _on_toy_dropped() -> void:
	game_stats.add_score(100)
	if game_stats.toys_left > 1:
		game_stats.toys_left -= 1
	else:
		objects_holder.toy_chest.close()
		spawning.spawn_key()


func _on_bomb_explode(pos: Vector2) -> void:
	spawning.spawn_explosion(pos)


func _on_demon_split_fireball(pos: Vector2) -> void:
	spawning.spawn_fireball(pos)
