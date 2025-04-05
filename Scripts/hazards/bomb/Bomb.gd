class_name Bomb extends Node2D

@export var anim: AnimatedSprite2D

signal explode


func _on_animation_finished() -> void:
	if anim.animation == "prepare":
		explode.emit(global_position)
		queue_free()


func _on_timer_timeout() -> void:
	anim.play("prepare")
