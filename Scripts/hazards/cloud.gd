class_name Cloud extends RandomChangeDirectionCharacter

@export var anim: AnimatedSprite2D

@export var storm_area: Area2D


func _physics_process(delta: float) -> void:
	if check_snapped(1.0):
		var direction: Vector2
		
		if change_direction_delay <= 0:
			direction = change_direction_to_random()
			change_direction_delay = 3
		else:
			change_direction_delay -= 1
		
		match direction:
			Vector2.RIGHT:
				if check_collision(check_right):
					change_direction()
				else:
					state = STATE.WALK_RIGHT
					move(direction)
			Vector2.LEFT:
				if check_collision(check_left):
					change_direction()
				else:
					state = STATE.WALK_LEFT
					move(direction)
			Vector2.DOWN:
				if check_collision(check_down):
					change_direction()
				else:
					state = STATE.WALK_DOWN
					move(direction)
			Vector2.UP:
				if check_collision(check_up):
					change_direction()
				else:
					state = STATE.WALK_UP
					move(direction)
	
	if velocity == Vector2.ZERO:
		snap_to_grid()
	
	move_and_slide()


func check_collision(collision_area: Area2D) -> bool:
	for i in collision_area.get_overlapping_bodies():
		if i is Aoy:
			return false
		if i is Enemy:
			return false
	
	if collision_area.has_overlapping_bodies(): return true
	else: return false


func _on_storm_area_body_entered(body: Node2D) -> void:
	if body is Aoy:
		if not body.is_invincibility:
			body.hit()

func _on_storm_delay_timeout() -> void:
	storm_area.monitoring = true
	anim.play("StormCloud")


func _on_animation_finished() -> void:
	if anim.animation == "StormCloud":
		storm_area.monitoring = false
		anim.play("Cloud")
