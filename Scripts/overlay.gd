class_name Overlay extends Control

enum Event { StartGame, ChangeLevel, RestartGame }

enum XobSpawnSide { Top, Bottom, Left, Right }

@export_category("Scenes")
@export var balloon: PackedScene
@export var treat: PackedScene
@export var card: PackedScene
@export var toy: PackedScene
@export var key: PackedScene
@export var power_up: PackedScene
@export var gemstone: PackedScene
@export var enemy_respawn_anim: PackedScene
@export var tic: PackedScene
@export var tac: PackedScene
@export var toe: PackedScene
@export var fire_bubble: PackedScene
@export var jack_in_the_box: PackedScene
@export var xob: PackedScene
@export var fade: PackedScene
@export var menu: PackedScene
@export var first_level: PackedScene

@export_category("Nodes")
@export var viewport: SubViewport

var event: Event
var _menu: Menu
var level: SceneController
var change_on_level: PackedScene

var lives := 3

var current_balloon: Balloons.BALLOON_TYPE = 0

const respawn_delay := 3
var respawn_delay_timer := Timer.new()


func _ready() -> void:
	randomize()
	return_to_menu()
	
	respawn_delay_timer.one_shot = true
	add_child(respawn_delay_timer)


func _on_start_game() -> void:
	event = Event.StartGame
	fade_in()

func _on_restart() -> void:
	if lives > 0:
		event = Event.ChangeLevel
		lives -= 1
	else:
		event = Event.RestartGame
		lives = 3
	
	respawn_delay_timer.stop()
	fade_in()

func _on_next_level(scene: PackedScene) -> void:
	event = Event.ChangeLevel
	change_on_level = scene
	
	fade_in()


func fade_in() -> void:
	var obj: Fade = fade.instantiate()
	obj.fade_in_over.connect(_on_fade_in_over)
	viewport.add_child(obj)
	obj.start_fade_in()

func _on_fade_in_over() -> void:
	match event:
		Event.StartGame:
			_menu.queue_free()
			start_scene(first_level)
			change_on_level = first_level
		Event.ChangeLevel:
			level.queue_free()
			start_scene(change_on_level)
		Event.RestartGame:
			level.queue_free()
			return_to_menu()
	
	get_tree().paused = false


func start_scene(_scene: PackedScene) -> void:
	var scene: SceneController = _scene.instantiate()
	
	level = scene
	
	scene.restart.connect(_on_restart)
	scene.next_level.connect(_on_next_level)
	scene.balloon_popped.connect(_on_balloon_popped)
	scene.spawn_balloon.connect(spawn_balloon)
	scene.spawn_card.connect(spawn_card)
	scene.spawn_fire_bubble.connect(spawn_fire_bubble)
	scene.spawn_gemstones.connect(spawn_gemstones)
	scene.spawn_jack_in_the_box.connect(spawn_jack_in_the_box)
	scene.spawn_key.connect(spawn_key)
	scene.spawn_power_up.connect(spawn_power_up)
	scene.spawn_toy.connect(spawn_toy)
	scene.spawn_treat.connect(spawn_treat)
	scene.spawn_xob.connect(spawn_xob)
	scene.respawn_enemy.connect(respawn_enemy)
	viewport.add_child(scene)
	scene.set_lives(lives)


func spawn_toy(texture: Texture2D) -> void:
	var obj: Toy = toy.instantiate()
	obj.position = level.pick_random_pos()
	level.add_child(obj)
	obj.set_sprite(texture)
	level.toys_left += 1

func spawn_card() -> void:
	var obj: Cards = card.instantiate()
	obj.picked.connect(level._on_card_picked)
	obj.position = level.pick_random_pos()
	level.add_child(obj)

func spawn_balloon() -> void:
	if current_balloon != Balloons.BALLOON_TYPE.Nothing:
		var obj: Balloons = balloon.instantiate()
		obj.balloon_type = current_balloon
		obj.position = level.pick_random_pos()
		obj.popped.connect(level._on_balloon_popped)
		level.add_child(obj)
		
		level.balloon = obj
		
		level.pop_balloon_timer.start(level.pop_balloon_delay)

func spawn_treat() -> void:
	if not level.is_treat_picked:
		level.current_treat = 0
	level.is_treat_picked = false
	
	if level.treat != null: level.treat.queue_free()
	
	var obj: Treats = treat.instantiate()
	obj.treat_type = level.current_treat
	obj.picked.connect(level._on_treat_picked)
	obj.position = level.pick_random_pos()
	level.add_child(obj)
	
	level.treat = obj

func spawn_key() -> void:
	var obj: Key = key.instantiate()
	obj.picked.connect(level._on_key_picked)
	obj.position = level.pick_random_pos()
	level.add_child(obj)

func spawn_power_up() -> void:
	var obj: PowerUp = power_up.instantiate()
	obj.power_up_type = randi() % PowerUp.POWER_UP_TYPE.size()
	obj.position = level.pick_random_pos()
	level.add_child(obj)

func spawn_gemstones() -> void:
	var segment := 0
	
	for x in range(level.map_size.position.x, level.map_size.size.x):
		for y in range(level.map_size.position.y, level.map_size.size.y):
			var obj_pos: Vector2i = Vector2i(x, y)
			
			if level.tiles.get_cell_atlas_coords(obj_pos - Vector2i.ONE) == Vector2i(1, 0) \
			and segment == 0:
				var obj: Gemstone = gemstone.instantiate()
				obj.picked.connect(level._on_gemstone_picked)
				
				obj.position = obj_pos * 16
				
				level.add_child(obj)
				level.gemstones.append(obj)
			
			if segment < 1: segment += 1
			else: segment = 0


func spawn_fire_bubble(pos: Vector2, direction: FireBubble.DIRECTION) -> void:
	var obj: FireBubble = fire_bubble.instantiate()
	obj.direction = direction
	obj.position = pos
	level.add_child(obj)

func spawn_jack_in_the_box(pos: Vector2) -> void:
	var obj: JackInTheBox = jack_in_the_box.instantiate()
	obj.position = pos
	level.add_child(obj)


func spawn_xob() -> void:
	var obj: Xob = xob.instantiate()
	var side: XobSpawnSide = randi() % XobSpawnSide.size()
	
	match side:
		XobSpawnSide.Top:
			obj.position = Vector2(randf_range(level.map_size.position.x * 16, level.map_size.size.x * 16), \
			level.map_size.position.y * 16)
		XobSpawnSide.Bottom:
			obj.position = Vector2(randf_range(level.map_size.position.x * 16, level.map_size.size.x * 16), \
			level.map_size.size.y * 16)
		XobSpawnSide.Left:
			obj.position = Vector2(level.map_size.position.x * 16, \
			randf_range(level.map_size.position.y * 16, level.map_size.size.y * 16))
		XobSpawnSide.Right:
			obj.position = Vector2(level.map_size.size.x * 16, \
			randf_range(level.map_size.position.y * 16, level.map_size.size.y * 16))
	
	obj.position += level.map_offset
	
	level.add_child(obj)
	
	level.xob = obj


func respawn_enemy(type: Enemy.TYPE) -> void:
	var anim: AnimatedSprite2D = enemy_respawn_anim.instantiate()
	anim.position = level.pick_random_pos()
	
	level.add_child(anim)
	
	respawn_delay_timer.start(respawn_delay)
	await respawn_delay_timer.timeout
	
	var obj: Enemy
	
	match type:
		Enemy.TYPE.Tic:
			obj = tic.instantiate()
		Enemy.TYPE.Tac:
			obj = tac.instantiate()
		Enemy.TYPE.Toe:
			obj = toe.instantiate()
	
	obj.map_offset = level.map_offset
	obj.defeated.connect(level._on_enemy_defeated)
	obj.position = anim.position
	
	level.add_child(obj)
	level.enemies.append(obj)
	
	anim.queue_free()


func return_to_menu() -> void:
	var obj: Menu = menu.instantiate()
	obj.start_game.connect(_on_start_game)
	viewport.add_child(obj)
	_menu = obj
	
	current_balloon = 0


func _on_balloon_popped() -> void:
	if current_balloon < Balloons.BALLOON_TYPE.size() - 1:
		current_balloon += 1
