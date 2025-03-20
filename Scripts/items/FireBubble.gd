class_name FireBubble extends Area2D

enum DIRECTION {
	Right,
	Left,
	Up,
	Down
}

@export var anim: AnimatedSprite2D

var direction: DIRECTION
var speed := 40.0


func _physics_process(delta: float) -> void:
	match direction:
		DIRECTION.Right:
			translate(Vector2.RIGHT * speed / 100)
		DIRECTION.Left:
			translate(Vector2.LEFT * speed / 100)
		DIRECTION.Up:
			translate(Vector2.UP * speed / 100)
		DIRECTION.Down:
			translate(Vector2.DOWN * speed / 100)


func _on_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.defeat()
		anim.play("popped")


func _on_animation_finished() -> void:
	if anim.animation == "popped":
		queue_free()
