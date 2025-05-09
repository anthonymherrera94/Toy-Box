class_name SpawningSyrup extends Node


func _on_timer_timeout() -> void:
	var parent = get_parent()
	
	if parent is SceneController:
		parent.spawning.spawn_syrup()
