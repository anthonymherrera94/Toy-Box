class_name Enemy extends Character

enum TYPE {
	Tic,
	Tac,
	Toe
}

var map_offset: Vector2

@export var player_anim: AnimatedSprite2D
@export var navigation: NavigationAgent2D

@export var type: TYPE

@export_category("RayCasts")
@export var down_raycast: RayCast2D
@export var up_raycast: RayCast2D
@export var left_raycast: RayCast2D
@export var right_raycast: RayCast2D

var change_direction_delay := 0

signal defeated


func _process(delta):
	animate()
	
func _physics_process(delta):
	if check_snapped(1.0):
		var direction: Vector2
		
		if right_raycast.get_collider() is Aoy:
			direction = Vector2.RIGHT
		elif left_raycast.get_collider() is Aoy:
			direction = Vector2.LEFT
		elif up_raycast.get_collider() is Aoy:
			direction = Vector2.UP
		elif down_raycast.get_collider() is Aoy:
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
	

func check_collision(collision_area: Area2D) -> bool:
	for i in collision_area.get_overlapping_bodies():
		if i is Aoy:
			return false
	
	if collision_area.has_overlapping_bodies(): return true
	else: return false


func animate():
	match state:
		STATE.WALK_RIGHT:
			player_anim.play("WalkRight")
		STATE.WALK_LEFT:
			player_anim.play("WalkLeft")
		STATE.WALK_UP:
			player_anim.play("WalkUp")
		STATE.WALK_DOWN:
			player_anim.play("WalkDown")


func defeat():
	defeated.emit(type)
	queue_free()
