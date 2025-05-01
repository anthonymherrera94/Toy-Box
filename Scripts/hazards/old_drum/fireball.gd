class_name OilDrumFireball extends Area2D

@export var anim: AnimatedSprite2D

signal hit


func _on_body_entered(body: Node2D) -> void:
	if body is Aoy:
		if not body.is_invincibility:
			body.hit()
			hit.emit()


func _on_animation_finished() -> void:
	if anim.animation == "Spawn":
		anim.play("Idle")
