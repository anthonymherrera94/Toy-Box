class_name Door extends Area2D

@export var sprite: AnimatedSprite2D

signal indoor


func open_door() -> void:
	sprite.play("Opened")


func _on_body_entered(body: Node2D) -> void:
	if body is Aoy:
		if body.picked_key:
			indoor.emit()
