class_name XobInTrueFormFireball extends RandomChangeDirectionCharacter

@export var anim: AnimatedSprite2D

var direction := Vector2.ZERO


func _process(delta) -> void:
	animate()

func _physics_process(delta) -> void:
	if check_snapped(2.0) and snap_delay.is_stopped():
		snap_to_grid()

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
			
			_:
				pass
	
	super(delta)


func check_collision(collision_area: Area2D) -> bool:
	for i in collision_area.get_overlapping_bodies():
		if i is Aoy:
			return false
	
	return collision_area.has_overlapping_bodies()


func animate() -> void:
	match state:
		STATE.WALK_RIGHT:
			anim.rotation_degrees = 270
		STATE.WALK_LEFT:
			anim.rotation_degrees = 90
		STATE.WALK_UP:
			anim.rotation_degrees = 180
		STATE.WALK_DOWN:
			anim.rotation_degrees = 0


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		turn_around()

func turn_around() -> void:
	match state:
		STATE.WALK_RIGHT:
			if check_collision(check_left):
				change_direction()
			else:
				state = STATE.WALK_LEFT
				direction = Vector2.LEFT
				move(direction)
		
		STATE.WALK_LEFT:
			if check_collision(check_right):
				change_direction()
			else:
				state = STATE.WALK_RIGHT
				direction = Vector2.RIGHT
				move(direction)
		
		STATE.WALK_UP:
			if check_collision(check_down):
				change_direction()
			else:
				state = STATE.WALK_DOWN
				direction = Vector2.DOWN
				move(direction)
		
		STATE.WALK_DOWN:
			if check_collision(check_up):
				change_direction()
			else:
				state = STATE.WALK_UP
				direction = Vector2.UP
				move(direction)
	


func _on_self_destructing_timeout() -> void:
	queue_free()
