class_name Enemy extends RandomChangeDirectionCharacter

enum TYPE {
	Tic,
	Tac,
	Toe
}

@export var enemy_anim: AnimatedSprite2D

@export var type: TYPE

@export var respawn_delay: Timer

@export_category("RayCasts")
@export var down_raycast: RayCast2D
@export var up_raycast: RayCast2D
@export var left_raycast: RayCast2D
@export var right_raycast: RayCast2D

signal defeated

var direction := Vector2.ZERO


func _process(delta) -> void:
	if check_state():
		animate()

func check_state() -> bool:
	if state != STATE.FLATTEN and state != STATE.SCARED and state != STATE.TRAPPED:
		return true
	return false

func _physics_process(delta) -> void:
	if check_snapped(2.0) and check_state() and snap_delay.is_stopped():
		snap_to_grid()

		if check_side_for_player(left_raycast):
			direction = Vector2.LEFT
		elif check_side_for_player(right_raycast):
			direction = Vector2.RIGHT
		elif check_side_for_player(up_raycast):
			direction = Vector2.UP
		elif check_side_for_player(down_raycast):
			direction = Vector2.DOWN
		else:
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


func check_side_for_player(raycast: RayCast2D) -> bool:
	var obj := raycast.get_collider()
	if obj is Aoy:
		if not obj.is_invincibility:
			return true
	
	return false

func check_collision(collision_area: Area2D) -> bool:
	for i in collision_area.get_overlapping_bodies():
		if i is Aoy:
			return false
	
	return collision_area.has_overlapping_bodies()


func animate() -> void:
	match state:
		STATE.WALK_RIGHT:
			enemy_anim.play("WalkRight")
		STATE.WALK_LEFT:
			enemy_anim.play("WalkLeft")
		STATE.WALK_UP:
			enemy_anim.play("WalkUp")
		STATE.WALK_DOWN:
			enemy_anim.play("WalkDown")
		STATE.FLATTEN:
			enemy_anim.play("Flatten")
		STATE.SCARED:
			enemy_anim.play("Scared")
		STATE.TRAPPED:
			enemy_anim.play("Trapped")


func flat() -> void:
	if check_state():
		snap_to_grid()

		state = STATE.FLATTEN
		animate()
		disable_collision()

		respawn_delay.start()

func scared() -> void:
	if check_state():
		snap_to_grid()

		state = STATE.SCARED
		animate()
		disable_collision()

		respawn_delay.start()

func trapped() -> void:
	if check_state():
		snap_to_grid()

		state = STATE.TRAPPED
		animate()
		disable_collision()

		respawn_delay.start()

func disable_collision() -> void:
	collision_layer = 0
	collision_mask = 0


func _on_respawn_delay_timeout() -> void:
	defeat()

func defeat() -> void:
	defeated.emit(type, start_pos)
	get_parent().queue_free()


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
