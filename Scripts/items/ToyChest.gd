class_name ToyChest extends Area2D

signal toy_dropped


func _on_body_entered(body: Node2D) -> void:
	if body is Aoy:
		if body.picked_toy:
			body.drop_toy()
			toy_dropped.emit()
