class_name Toy extends Area2D

@export var sprite: Sprite2D

var texture: Texture2D


func set_sprite(_texture: Texture2D) -> void:
	texture = _texture
	sprite.texture = texture


func _on_body_entered(body: Node2D) -> void:
	if body is Aoy:
		if not body.picked_toy:
			body.pick_toy(texture)
			queue_free()
