class_name Skull extends StaticBody2D

@export var anim: AnimatedSprite2D


func set_look_at_pos(pos: Vector2) -> void:
	var direction := global_position.angle_to(pos)
	direction = rad_to_deg(direction)
	check_look_at(0, 45, direction, "0")
	check_look_at(45, 90, direction, "45")
	check_look_at(90, 135, direction, "90")
	check_look_at(135, 180, direction, "135")
	check_look_at(180, 225, direction, "180")
	check_look_at(225, 270, direction, "225")
	check_look_at(270, 315, direction, "270")
	check_look_at(315, 360, direction, "315")


func check_look_at(min_direction: float, max_direction: float, current_direction: float, animation_: String) -> void:
	if current_direction > min_direction and current_direction < max_direction:
		anim.play(animation_)
