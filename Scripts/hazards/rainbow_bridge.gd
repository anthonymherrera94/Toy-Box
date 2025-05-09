class_name RainbowBridge extends StaticBody2D

@export var anim: AnimatedSprite2D

@export var spawn_timer: Timer
@export var hide_timer: Timer


func _ready() -> void:
	anim.hide()


func _on_animation_finished() -> void:
	match anim.animation:
		"Hide":
			anim.hide()
		"Show":
			anim.play("Idle")
			make_walkthroughable()


func make_solid() -> void:
	collision_layer = 1
	collision_mask = 1

func make_walkthroughable() -> void:
	collision_layer = 0
	collision_mask = 0


func _on_spawn_timeout() -> void:
	anim.show()
	anim.play("Show")
	hide_timer.start()


func _on_hide_timeout() -> void:
	anim.play("Hide")
	make_solid()
	spawn_timer.start()
