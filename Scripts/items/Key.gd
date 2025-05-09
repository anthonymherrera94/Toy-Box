class_name Key extends Area2D

signal picked


func _on_body_entered(body: Node2D) -> void:
	if body is Aoy:
		body.picked_key = true
		picked.emit()
		queue_free()
