class_name Character extends CharacterBody2D

var map_offset := Vector2(8, 8)

@export var speed := 80

@export_category("Checkers")
@export var check_left: Area2D
@export var check_right: Area2D
@export var check_up: Area2D
@export var check_down: Area2D

var start_pos: Vector2

var state = STATE.IDLE_RIGHT

var snap_delay := Timer.new()

var speed_ := Vector2.ZERO


enum STATE{
	IDLE_DOWN,
	IDLE_UP,
	IDLE_LEFT,
	IDLE_RIGHT,
	WALK_DOWN,
	WALK_UP,
	WALK_LEFT,
	WALK_RIGHT,
	HIT,
	KO,
	VICTORY,
	FLATTEN,
	SCARED,
	TRAPPED
}

func _ready() -> void:
	start_pos = global_position
	snap_to_grid()
	
	snap_delay.one_shot = true
	add_child(snap_delay)
	snap_delay.start(0.5)
	

func _physics_process(delta: float) -> void:
	velocity = speed_
	
	move_and_slide()
	

func set_state(_state):
	state = _state
	

func handle_state():
	match state:
		STATE.IDLE_DOWN:
			state_idle_down()
		STATE.IDLE_UP:
			state_idle_up()
		STATE.IDLE_LEFT:
			state_idle_left()
		STATE.IDLE_RIGHT:
			state_idle_right()
		STATE.WALK_DOWN:
			state_walk_down()
		STATE.WALK_UP:
			state_walk_up()
		STATE.WALK_LEFT:
			state_walk_left()
		STATE.WALK_RIGHT:
			state_walk_right()
	

func check_snapped(delimeter: float) -> bool:
	var snapped_pos = global_position.snappedf(16)
	if global_position.distance_to(snapped_pos) < delimeter:
		return true
	else:
		return false

func move(direction: Vector2) -> void:
	snap_to_grid()
	speed_ = direction * speed
	snap_delay.start(0.05)

func snap_to_grid() -> void:
	var snapped_pos = global_position.snappedf(16)
	global_position = snapped_pos
	speed_ = Vector2.ZERO


func state_idle_down():
	pass

func state_idle_up():
	pass
	
func state_idle_left():
	pass

func state_idle_right():
	pass

func state_walk_down():
	pass

func state_walk_up():
	pass
	
func state_walk_left():
	pass

func state_walk_right():
	pass 
