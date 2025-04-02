class_name Ball extends Area2D

enum Directions {
	Right,
	Down,
	Left,
	Up
}

var directions := {
	Directions.Right: 0,
	Directions.Down: 270,
	Directions.Left: 180,
	Directions.Up: 90
}

var direction: Directions = 0


func _physics_process(delta: float) -> void:
	translate(Vector2.from_angle(deg_to_rad(directions[direction])))


func _on_body_entered(body: Node2D) -> void:
	if body is Aoy:
		if not body.is_invincibility:
			body.hit()
		return
	
	if body is Enemy:
		return
	
	if direction < Directions.size() - 1:
		direction += 1
	else:
		direction = 0
