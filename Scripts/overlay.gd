class_name Overlay extends Control

enum Event { StartGame, ChangeLevel, RestartGame }

@export_category("Scenes")
@export var balloon: PackedScene
@export var treat: PackedScene
@export var card: PackedScene
@export var toy: PackedScene
@export var key: PackedScene
@export var power_up: PackedScene
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


func _ready() -> void:
	randomize()
	return_to_menu()


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
	scene.restart.connect(_on_restart)
	scene.next_level.connect(_on_next_level)
	scene.balloon_scene = balloon
	scene.treat_scene = treat
	scene.card_scene = card
	scene.toy_scene = toy
	scene.key_scene = key
	scene.xob_scene = xob
	scene.power_up_scene = power_up
	viewport.add_child(scene)
	scene.set_lives(lives)
	level = scene

func return_to_menu() -> void:
	var obj: Menu = menu.instantiate()
	obj.start_game.connect(_on_start_game)
	viewport.add_child(obj)
	_menu = obj
