class_name Spikes extends Area2D

@export var anim: AnimatedSprite2D


func _on_animation_finished() -> void:
	if anim.animation == "Active":
		anim.play("Inactive")
		make_inactive()

func _on_activate_timeout() -> void:
	anim.play("Active")
	make_active()


func make_active() -> void:
	monitoring = true

func make_inactive() -> void:
	monitoring = false


func _on_body_entered(body: Node2D) -> void:
	if body is Aoy:
		if not body.is_invincibility:
			body.hit()
