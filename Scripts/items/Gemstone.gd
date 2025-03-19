class_name Gemstone extends Area2D

@export var textures: Array[Texture2D]

@export var sprite: Sprite2D

signal picked


func _ready() -> void:
	sprite.texture = textures.pick_random()


func _on_body_entered(body: Node2D) -> void:
	if body is Aoy:
		picked.emit()
		queue_free()
