class_name ToyChest extends StaticBody2D

signal toy_dropped

@export var anim: AnimatedSprite2D


func open() -> void:
	anim.play("Open")

func close() -> void:
	anim.play("Close")

func _on_drop_area_entered(body: Node2D) -> void:
	if body is Aoy:
		if body.picked_toy:
			body.drop_toy()
			toy_dropped.emit()
