class_name DemonFireball extends Area2D

enum Direction {
	Right,
	Up,
	Left,
	Down
}

var directions := {
	Direction.Right: 0,
	Direction.Up: 90,
	Direction.Left: 180,
	Direction.Down: 270
}

var direction: Direction

@export var anim: AnimatedSprite2D


func _physics_process(delta: float) -> void:
	var dir = directions[direction]
	anim.rotation_degrees = -90 + dir
	translate(Vector2.from_angle(deg_to_rad(dir)))


func _on_body_entered(body: Node2D) -> void:
	if body is Aoy:
		if not body.is_invincibility:
			body.hit()

	queue_free()


func _on_animation_finished() -> void:
	if anim.animation == "Spawn":
		anim.play("Idle")
