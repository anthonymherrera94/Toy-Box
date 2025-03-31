class_name Enemy extends Character

enum TYPE {
	Tic,
	Tac,
	Toe
}

var map_offset: Vector2

@export var player_anim: AnimatedSprite2D

@export var type: TYPE

@export var respawn_delay: Timer

@export_category("RayCasts")
@export var down_raycast: RayCast2D
@export var up_raycast: RayCast2D
@export var left_raycast: RayCast2D
@export var right_raycast: RayCast2D

var change_direction_delay := 0

signal defeated


func _process(delta) -> void:
	if check_state():
		animate()

func check_state() -> bool:
	if state != STATE.FLATTEN and state != STATE.SCARED and state != STATE.TRAPPED:
		return true
	return false

func _physics_process(delta) -> void:
	if check_snapped(1.0) and check_state():
		var direction: Vector2
		
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
				direction = [
					Vector2.RIGHT,
					Vector2.LEFT,
					Vector2.UP,
					Vector2.DOWN
				].pick_random()
				change_direction_delay = 3
			else:
				change_direction_delay -= 1

		match direction:
			Vector2.RIGHT:
				if check_collision(check_right):
					snap_to_grid()
					change_direction_delay = 0
				else:
					state = STATE.WALK_RIGHT
					move(direction)
			Vector2.LEFT:
				if check_collision(check_left):
					snap_to_grid()
					change_direction_delay = 0
				else:
					state = STATE.WALK_LEFT
					move(direction)
			Vector2.DOWN:
				if check_collision(check_down):
					snap_to_grid()
					change_direction_delay = 0
				else:
					state = STATE.WALK_DOWN
					move(direction)
			Vector2.UP:
				if check_collision(check_up):
					snap_to_grid()
					change_direction_delay = 0
				else:
					state = STATE.WALK_UP
					move(direction)
	
	if velocity == Vector2.ZERO:
		snap_to_grid()
	
	move_and_slide()


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
	
	if collision_area.has_overlapping_bodies(): return true
	else: return false


func animate() -> void:
	match state:
		STATE.WALK_RIGHT:
			player_anim.play("WalkRight")
		STATE.WALK_LEFT:
			player_anim.play("WalkLeft")
		STATE.WALK_UP:
			player_anim.play("WalkUp")
		STATE.WALK_DOWN:
			player_anim.play("WalkDown")
		STATE.FLATTEN:
			player_anim.play("Flatten")
		STATE.SCARED:
			player_anim.play("Scared")
		STATE.TRAPPED:
			player_anim.play("Trapped")


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
	queue_free()
