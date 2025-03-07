class_name Fade extends CanvasLayer

@export var anim: AnimationPlayer
#var scene:PackedScene = null 


func start_fade_in(scene: PackedScene):
	anim.play("fade_in")
	#scene = _scene
	await anim.animation_finished
	get_tree().change_scene_to_file(scene.resource_path)
	queue_free()




#func _on_animation_player_animation_finished(anim_name):
	#if anim_name == "fade_in":
		#get_tree().change_scene_to_packed(scene)
