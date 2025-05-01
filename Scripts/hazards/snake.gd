class_name Snake extends Area2D

enum Direction {
	Bottom,
	Right,
	Left
}

@export var anim: AnimatedSprite2D
@export var direction: Direction


func _ready() -> void:
	monitoring = false

	match direction:
		Direction.Bottom:
			anim.position += Vector2.UP * 16
			anim.play("Hole")
		
		Direction.Right:
			anim.offset = Vector2.ZERO
			anim.hide()
		
		Direction.Left:
			anim.offset = Vector2.ZERO
			anim.scale.x = -1
			anim.hide()


func push_snake() -> void:
	match direction:
		Direction.Bottom:
			anim.play("Bottom")
		
		Direction.Right:
			anim.play("Side")
			anim.show()
		
		Direction.Left:
			anim.play("Side")
			anim.show()

	monitoring = true


func _on_animation_finished() -> void:
	match direction:
		Direction.Bottom:
			anim.play("Hole")
		
		Direction.Right, Direction.Left:
			anim.hide()

	monitoring = false


func _on_body_entered(body: Node2D) -> void:
	if body is Aoy:
		if not body.is_invincibility:
			body.hit()
