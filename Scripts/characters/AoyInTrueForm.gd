class_name AoyInTrueForm extends Character

@export var anim: AnimatedSprite2D

var movement_bounds: Rect2

signal change_pos

signal game_end


func _process(delta: float) -> void:
	animate()


func _physics_process(delta):
	if check_snapped(2.0) and snap_delay.is_stopped():
		snap_to_grid()
		change_pos.emit(global_position)

		var input = get_input()
		
		if input.x > 0:
			if movement_bounds.size.x < global_position.x:
				state = STATE.WALK_RIGHT
				move(Vector2.RIGHT)
		
		elif input.x < 0:
			if movement_bounds.position.x > global_position.x:
				state = STATE.WALK_LEFT
				move(Vector2.LEFT)
		
		if input.y > 0:
			if movement_bounds.size.y < global_position.y:
				state = STATE.WALK_DOWN
				move(Vector2.DOWN)
		
		elif input.y < 0:
			if movement_bounds.position.y > global_position.y:
				state = STATE.WALK_UP
				move(Vector2.UP)

		if input == Vector2.ZERO:
			match state:
				STATE.WALK_RIGHT:
					state = STATE.IDLE_RIGHT
					snap_to_grid()
				
				STATE.WALK_LEFT:
					state = STATE.IDLE_LEFT
					snap_to_grid()
				
				STATE.WALK_UP:
					state = STATE.IDLE_UP
					snap_to_grid()
				
				STATE.WALK_DOWN:
					state = STATE.IDLE_DOWN
					snap_to_grid()
	
	super(delta)


func get_input() -> Vector2:
	return Vector2(Input.get_axis("move_left", "move_right"), \
	Input.get_axis("move_up", "move_down"))


func animate():
	match state:
		STATE.IDLE_LEFT:
			anim.play("IdleLeft")
		
		STATE.IDLE_RIGHT:
			anim.play("IdleRight")
		
		STATE.IDLE_UP:
			anim.play("IdleUp")
		
		STATE.IDLE_DOWN:
			anim.play("IdleDown")

		STATE.WALK_LEFT:
			anim.play("WalkLeft")
		
		STATE.WALK_RIGHT:
			anim.play("WalkRight")
		
		STATE.WALK_UP:
			anim.play("WalkUp")
		
		STATE.WALK_DOWN:
			anim.play("WalkDown")


func _on_colliding_body_entered(body: Node2D):
	if body is Enemy:
		body.scared()


func _on_area_entered(area: Area2D) -> void:
	if area is XobInTrueForm:
		game_end.emit()
		area.queue_free()
