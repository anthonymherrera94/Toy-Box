class_name Enemy extends Character

enum TYPE {
	Tic,
	Tac,
	Toe
}

enum Direction {
	Right,
	Left,
	Up,
	Down
}

var map_offset: Vector2

var move_speed := 60.0
@export var player_anim: AnimatedSprite2D
@export var navigation: NavigationAgent2D

@export var type: TYPE

@export_category("RayCasts")
@export var down_raycast: RayCast2D
@export var up_raycast: RayCast2D
@export var left_raycast: RayCast2D
@export var right_raycast: RayCast2D

var change_direction_delay := 0

var direction: Direction

signal defeated


func _process(delta):
	animate()
	
func _physics_process(delta):
	move()
	move_and_slide()
	
func move():
	var snapped_pos = position.snapped(Vector2(16, 16))
	
	if position.distance_to(snapped_pos) < 1:
		position = snapped_pos
		
		if right_raycast.get_collider() is Aoy:
			direction = Direction.Right
		elif left_raycast.get_collider() is Aoy:
			direction = Direction.Left
		elif up_raycast.get_collider() is Aoy:
			direction = Direction.Up
		elif down_raycast.get_collider() is Aoy:
			direction = Direction.Down
		else:
			if change_direction_delay <= 0:
				direction = randi() % Direction.size()
				change_direction_delay = 3
			else:
				change_direction_delay -= 1
		
		match direction:
			Direction.Right:
				if check_collision(check_right):
					velocity = Vector2.ZERO
					change_direction_delay = 0
				else:
					state = STATE.WALK_RIGHT
					velocity = Vector2.RIGHT * move_speed
			Direction.Left:
				if check_collision(check_left):
					velocity = Vector2.ZERO
					change_direction_delay = 0
				else:
					state = STATE.WALK_LEFT
					velocity = Vector2.LEFT * move_speed
			Direction.Down:
				if check_collision(check_down):
					velocity = Vector2.ZERO
					change_direction_delay = 0
				else:
					state = STATE.WALK_DOWN
					velocity = Vector2.DOWN * move_speed
			Direction.Up:
				if check_collision(check_up):
					velocity = Vector2.ZERO
					change_direction_delay = 0
				else:
					state = STATE.WALK_UP
					velocity = Vector2.UP * move_speed
	
	if velocity == Vector2.ZERO:
		position = snapped_pos


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
