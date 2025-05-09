class_name Ball extends Area2D

enum Directions {
	Right,
	Down,
	Left,
	Up
}

var directions := {
	Directions.Right: 0,
	Directions.Down: 90,
	Directions.Left: 180,
	Directions.Up: 270
}

@export var direction := Directions.Right


func _physics_process(delta: float) -> void:
	translate(Vector2.from_angle(deg_to_rad(directions[direction])))


func _on_body_entered(body: Node2D) -> void:
	if body is Aoy:
		if not body.is_invincibility:
			body.hit()
		return
	
	if body is Enemy:
		return
	
	if body is XobInTrueFormFireball:
		return
	
	if direction < Directions.size() - 1:
		snap_to_grid()
		direction += 1
	else:
		snap_to_grid()
		direction = 0


func snap_to_grid() -> void:
	var snapped_pos = global_position.snappedf(16)
	global_position = snapped_pos
