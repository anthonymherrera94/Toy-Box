extends Node


func fade_in(scene):
	var fade_scene = preload("res://Scenes/fade.tscn")
	var scene_obj = fade_scene.instantiate()
	get_parent().add_child(scene_obj)
	scene_obj.start_fade_in(scene)
