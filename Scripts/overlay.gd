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

var popped_balloons: Array[Balloons.TYPE]
var current_balloon: Balloons.TYPE = 0


func _ready() -> void:
	randomize()
	return_to_menu()
	
	treats_respawn_timer.timeout.connect(func(): level.spawn_treat())
	bonus_round_timer.timeout.connect(_on_bonus_round_time_end)
	bonus_time_tick.timeout.connect(_on_bonus_time_tick)


func _on_start_game() -> void:
	event = Event.StartGame
	fade_in()

func _on_restart() -> void:
	event = Event.ChangeLevel
	
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


func start_scene(_scene: PackedScene) -> void:
	var scene: SceneController = _scene.instantiate()
	
	level = scene
	
	scene.balloon = balloon
	scene.treat = treat
	scene.card = card
	scene.toy = toy
	scene.key = key
	scene.power_up = power_up
	scene.gemstone = gemstone
	scene.enemy_respawn_anim = enemy_respawn_anim
	scene.tic = tic
	scene.tac = tac
	scene.toe = toe
	scene.fire_bubble = fire_bubble
	scene.jack_in_the_box = jack_in_the_box
	scene.xob = xob
	scene.bonus_round_timer = bonus_round_timer
	scene.respawn_delay_timer = respawn_delay_timer
	scene.current_balloon = current_balloon
	
	viewport.add_child(scene)
	
	scene.restart.connect(_on_restart)
	scene.next_level.connect(_on_next_level)
	
	for i in popped_balloons:
		scene.set_popped_balloon(i)
	
	treats_respawn_timer.start()
	bonus_time_tick.start()


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
