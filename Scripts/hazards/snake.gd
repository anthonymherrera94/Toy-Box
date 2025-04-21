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
			anim.play("Hole")
		Direction.Right:
			position += Vector2.RIGHT * 16
			anim.offset = Vector2.ZERO
			anim.hide()
		Direction.Left:
			position += Vector2.LEFT * 16
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


func _on_animation_finished() -> void:
	match direction:
		Direction.Bottom:
			anim.play("Hole")
		Direction.Right, Direction.Left:
			anim.hide()
