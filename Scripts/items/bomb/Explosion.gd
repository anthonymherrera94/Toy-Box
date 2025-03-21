class_name Explosion extends Node2D

enum TYPE {
	Cross,
	Vertical,
	Horizontal
}

@export var anim: AnimatedSprite2D

var type: TYPE


func _ready() -> void:
	match type:
		TYPE.Cross:
			anim.play("Cross")
		TYPE.Vertical:
			anim.play("Line")
		TYPE.Horizontal:
			anim.rotation_degrees = 90
			anim.play("Line")


func _on_timer_timeout() -> void:
	queue_free()
