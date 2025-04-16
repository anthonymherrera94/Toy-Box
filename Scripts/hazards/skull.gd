class_name Skull extends StaticBody2D

@export var anim: AnimatedSprite2D
@export var look: RayCast2D


func set_look_at_pos(pos: Vector2) -> void:
	look.look_at(pos)

	var direction = look.rotation_degrees

	check_look_at(0, 45, direction, "Right")
	check_look_at(45, 90, direction, "RightDown")
	check_look_at(90, 135, direction, "Down")
	check_look_at(135, 180, direction, "LeftDown")
	check_look_at(180, 225, direction, "Left")
	check_look_at(225, 270, direction, "LeftUp")
	check_look_at(270, 315, direction, "Up")
	check_look_at(315, 360, direction, "RightUp")


func check_look_at(min_direction: float, max_direction: float, current_direction: float, animation_: String) -> void:
	while (current_direction < 0):
		current_direction += 360

	while (current_direction > 360):
		current_direction -= 360

	if current_direction > min_direction and current_direction < max_direction:
		anim.play(animation_)
