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
@export var syrup: PackedScene
@export var fade: PackedScene
@export var menu: PackedScene
@export var first_level: PackedScene

@export_category("Nodes")
@export var viewport: SubViewport

@export_category("Timers")
@export var treats_spawn_timer: Timer
@export var treats_picked_delay: Timer
@export var balloon_pop_delay: Timer
@export var bonus_round_timer: Timer
@export var respawn_delay_timer: Timer
@export var bonus_time_tick: Timer

var event: Event
var _menu: Menu
var level: Node2D
var change_on_level: PackedScene

var current_treat: Treats.TYPE = 0

var popped_balloons: Array[Balloons.TYPE]
var current_balloon: Balloons.TYPE = 0


func _ready() -> void:
	randomize()
	return_to_menu()
	
	treats_spawn_timer.timeout.connect(func(): level.get_child(0).spawning.spawn_treat())
	bonus_round_timer.timeout.connect(_on_bonus_round_time_end)
	bonus_time_tick.timeout.connect(_on_bonus_time_tick)


func _on_start_game() -> void:
	event = Event.StartGame
	fade_in()

func _on_restart() -> void:
	event = Event.ChangeLevel
	
	treats_spawn_timer.stop()
	treats_picked_delay.stop()
	balloon_pop_delay.stop()
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
	var scene: Node2D = _scene.instantiate()
	var scene_controller: SceneController = scene.get_child(0)
	
	level = scene
	
	scene_controller.spawning.balloon = balloon
	scene_controller.spawning.treat = treat
	scene_controller.spawning.card = card
	scene_controller.spawning.toy = toy
	scene_controller.spawning.key = key
	scene_controller.spawning.power_up = power_up
	scene_controller.spawning.gemstone = gemstone
	scene_controller.spawning.enemy_respawn_anim = enemy_respawn_anim
	scene_controller.spawning.tic = tic
	scene_controller.spawning.tac = tac
	scene_controller.spawning.toe = toe
	scene_controller.spawning.fire_bubble = fire_bubble
	scene_controller.spawning.jack_in_the_box = jack_in_the_box
	scene_controller.spawning.xob = xob
	scene_controller.spawning.syrup = syrup
	scene_controller.treats_picked_delay = treats_picked_delay
	scene_controller.ballon_pop_delay = balloon_pop_delay
	scene_controller.bonus_round_timer = bonus_round_timer
	scene_controller.respawn_delay_timer = respawn_delay_timer
	scene_controller.game_stats.current_balloon = current_balloon
	scene_controller.game_stats.current_treat = current_treat
	
	viewport.add_child(scene)
	
	scene_controller.restart.connect(_on_restart)
	scene_controller.next_level.connect(_on_next_level)
	
	scene_controller.balloon_popped.connect(_on_balloon_popped)
	scene_controller.treat_picked.connect(_on_treat_picked)
	
	for i in popped_balloons:
		scene_controller.game_stats.set_popped_balloon(i)
	
	treats_spawn_timer.start()
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

func _on_treat_picked() -> void:
	if current_treat < Treats.TYPE.size() - 1:
		current_treat += 1
	else:
		current_treat = 0


func _on_bonus_time_tick() -> void:
	if level != null: level.get_child(0).game_stats._on_bonus_time_tick()

func _on_bonus_round_time_end() -> void:
	if level != null: level.get_child(0)._on_bonus_round_time_end()
