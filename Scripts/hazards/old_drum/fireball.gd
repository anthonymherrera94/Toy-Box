class_name OilDrumFireball extends Area2D

signal hit


func _on_body_entered(body: Node2D) -> void:
	if body is Aoy:
		if not body.is_invincibility:
			body.hit()
			hit.emit()
