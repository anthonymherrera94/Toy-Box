class_name Cards extends Area2D

signal picked


func _on_body_entered(body: Node2D) -> void:
	if body is Aoy:
		picked.emit()
		queue_free()
