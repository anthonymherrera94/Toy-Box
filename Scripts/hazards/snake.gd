class_name Snake extends Area2D

enum Direction {
	Bottom,
	Right,
	Left
}

@export var anim: AnimatedSprite2D
@export var direction: Direction


func _ready() -> void:
	match direction:
		Direction.Bottom:
			anim.offset = Vector2.UP * 8
		Direction.Right:
			position += Vector2.RIGHT * 16
			anim.hide()
		Direction.Left:
			position += Vector2.LEFT * 16
			anim.scale.x = -1
			anim.hide()


func _on_body_entered(body: Node2D) -> void:
	if body is Aoy:
		match direction:
			Direction.Bottom:
				anim.play("Down")
			Direction.Right:
				anim.play("Side")
				anim.show()
			Direction.Left:
				anim.play("Side")
				anim.show()
		
		if not body.is_invincibility:
			body.hit()


func _on_animation_finished() -> void:
	match direction:
		Direction.Bottom:
			anim.play("Hole")
		Direction.Right, Direction.Left:
			anim.hide()
