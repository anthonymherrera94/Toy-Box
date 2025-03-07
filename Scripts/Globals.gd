extends Node

var prev_scene: PackedScene

func restart():
	fade_in(prev_scene)

func fade_in(scene: PackedScene):
	var fade_scene = preload("res://Scenes/fade.tscn")
	var scene_obj = fade_scene.instantiate()
	get_parent().add_child(scene_obj)
	scene_obj.start_fade_in(scene)
	prev_scene = scene
