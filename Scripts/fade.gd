class_name Fade extends CanvasLayer

@export var anim: AnimationPlayer
#var scene:PackedScene = null

signal fade_in_over


func start_fade_in():
	get_tree().paused = true
	play_fade_in_animation()
	#scene = _scene
	await anim.animation_finished
	get_tree().paused = false
	fade_in_over.emit()
	queue_free()

func play_fade_in_animation():
	anim.play("fade_in")



#func _on_animation_player_animation_finished(anim_name):
	#if anim_name == "fade_in":
		#get_tree().change_scene_to_packed(scene)
