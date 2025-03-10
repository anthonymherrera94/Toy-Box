extends Node

@onready var balloon = preload("res://Scenes/items/balloons.tscn")
@onready var treat = preload("res://Scenes/items/treats.tscn")

@onready var fade_scene = preload("res://Scenes/fade.tscn")


func fade_in(scene: PackedScene):
	var scene_obj = fade_scene.instantiate()
	get_parent().add_child(scene_obj)
	scene_obj.start_fade_in(scene)
