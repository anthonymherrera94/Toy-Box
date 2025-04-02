class_name Syrup extends Area2D

@export var fall_anim: AnimatedSprite2D
@export var puddle_anim: AnimatedSprite2D


func _on_fall_animation_finished() -> void:
	fall_anim.hide()
	puddle_anim.show()
	puddle_anim.play("Puddle")
	make_active()

func make_active() -> void:
	collision_layer = 1
	collision_mask = 1


func _on_body_entered(body: Node2D) -> void:
	if body is Aoy:
		body.slow_down()
		queue_free()


func _on_self_destruction_timeout() -> void:
	queue_free()
