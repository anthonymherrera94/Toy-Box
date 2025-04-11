class_name JackInTheBox extends Area2D

var speed := 40.0


func _on_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.scared()
		queue_free()
