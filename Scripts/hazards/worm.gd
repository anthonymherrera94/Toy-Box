class_name Worm extends StaticBody2D

@export var anim: AnimatedSprite2D


func _ready() -> void:
	make_walkthroughable()


func _on_showed_delay_timeout() -> void:
	anim.play("Showed")
	make_solid()

func _on_animation_finished() -> void:
	if anim.animation == "Showed":
		anim.play("Hided")
		make_walkthroughable()


func make_solid() -> void:
	collision_layer = 1
	collision_mask = 1

func make_walkthroughable() -> void:
	collision_layer = 0
	collision_mask = 0
