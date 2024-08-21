extends CharacterBody2D

class_name Character

enum STATE{
	IDLE_DOWN,
	IDLE_UP,
	IDLE_LEFT,
	IDLE_RIGHT,
	WALK_DOWN,
	WALK_UP,
	WALK_LEFT,
	WALK_RIGHT
}

var state = STATE.IDLE_DOWN

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
