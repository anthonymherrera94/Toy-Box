extends CanvasLayer


@onready var anim = $AnimationPlayer
var scene:PackedScene = null 

func start_fade_in(_scene):
	anim.play("fade_in")
	scene = _scene




func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fade_in":
		get_tree().change_scene_to_packed(scene)
