class_name XobInTrueForm extends Area2D

var speed := 0.5

var target_pos := Vector2.ZERO

signal spawn_fireball
signal target_reached


func change_target_pos(pos: Vector2) -> void:
	target_pos = pos


func _physics_process(delta: float) -> void:
	if global_position.distance_to(target_pos) > 4:
		translate(global_position.direction_to(target_pos) * speed)
	else:
		target_reached.emit()


func _on_body_entered(body: Node2D) -> void:
	if body is Aoy:
		if not body.is_invincibility:
			body.hit()


func _on_spawn_fireball_timeout() -> void:
	spawn_fireball.emit(global_position)
