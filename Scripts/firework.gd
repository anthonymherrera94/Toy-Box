class_name Firework extends AnimatedSprite2D

var colors: Array[String] = ["Blue", "Green", "Red"]


func _ready() -> void:
	play(colors.pick_random())


func _on_animation_finished() -> void:
	queue_free()
