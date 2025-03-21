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

@export_category("Timers")
@export var treats_respawn_timer: Timer
@export var bonus_round_timer: Timer
@export var respawn_delay_timer: Timer
@export var bonus_time_tick: Timer


var event: Event
var _menu: Menu
var level: SceneController
var change_on_level: PackedScene

var lives := 3

var popped_balloons: Array[Balloons.TYPE]
var current_balloon: Balloons.TYPE = 0


func _ready() -> void:
	randomize()
	return_to_menu()
	
	treats_respawn_timer.timeout.connect(spawn_treat)
	bonus_round_timer.timeout.connect(_on_bonus_round_time_end)
	bonus_time_tick.timeout.connect(_on_bonus_time_tick)


func _on_start_game() -> void:
	event = Event.StartGame
	fade_in()

func _on_lose_live() -> void:
	if lives > 0:
		lives -= 1
		
		level.set_lives(lives)
	else:
		event = Event.ChangeLevel
		lives = 3
		
		treats_respawn_timer.stop()
		bonus_round_timer.stop()
		respawn_delay_timer.stop()
		bonus_time_tick.stop()
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
	
	scene.lose_live.connect(_on_lose_live)
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
	scene.spawn_xob.connect(spawn_xob)
	scene.respawn_enemy.connect(respawn_enemy)
	viewport.add_child(scene)
	scene.set_lives(lives)
	
	for i in popped_balloons:
		scene.set_popped_balloon(i)
	
	treats_respawn_timer.start()
	bonus_time_tick.start()


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
	if current_balloon != Balloons.TYPE.Nothing:
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
	obj.power_up_type = randi() % PowerUp.TYPE.size()
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
			
			if segment < 3: segment += 1
			else: segment = 0
	
	bonus_round_timer.start()


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
			level.map_size.position.y * 16 - 2 * 16)
		XobSpawnSide.Bottom:
			obj.position = Vector2(randf_range(level.map_size.position.x * 16, level.map_size.size.x * 16), \
			level.map_size.size.y * 16 + 2 * 16)
		XobSpawnSide.Left:
			obj.position = Vector2(level.map_size.position.x * 16 - 2 * 16, \
			randf_range(level.map_size.position.y * 16, level.map_size.size.y * 16))
		XobSpawnSide.Right:
			obj.position = Vector2(level.map_size.size.x * 16 + 2 * 16, \
			randf_range(level.map_size.position.y * 16, level.map_size.size.y * 16))
	
	obj.position += level.map_offset
	
	level.add_child(obj)
	
	level.xob = obj


func respawn_enemy(type: Enemy.TYPE) -> void:
	var anim: AnimatedSprite2D = enemy_respawn_anim.instantiate()
	anim.position = level.pick_random_pos()
	
	level.add_child(anim)
	
	respawn_delay_timer.start(respawn_delay_timer.wait_time)
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


func _on_balloon_popped(type: Balloons.TYPE) -> void:
	if current_balloon < Balloons.TYPE.size() - 1:
		current_balloon += 1
		popped_balloons.append(type)


func _on_bonus_time_tick() -> void:
	if level != null: level._on_bonus_time_tick()

func _on_bonus_round_time_end() -> void:
	if level != null: level._on_bonus_round_time_end()
