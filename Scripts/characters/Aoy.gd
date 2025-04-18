class_name Aoy extends Character

var map_offset: Vector2

@export var slowing_move_speed := 60.0
@export var ordinary_move_speed := 80.0
@export var increased_move_speed := 120.0

@export var player_anim: AnimatedSprite2D

@export var hammer: AnimatedSprite2D
@export var bubble_gun: AnimatedSprite2D
@export var jack_in_the_box: Sprite2D

@export var toy: Sprite2D

@export var invincibility_timer: Timer
@export var slow_down_effect_timer: Timer

var picked_toy := false
var picked_key := false

var power_up_count := 0
var power_up_type: PowerUp.TYPE

var previous_state: STATE
var is_invincibility := false

signal change_pos
signal earn_score
signal power_up_picked
signal lose_live

signal shoot_fire_bubble
signal put_jack_in_the_box


func _ready() -> void:
	speed = ordinary_move_speed
	
	super()
	
func _process(delta):
	if Input.is_action_just_pressed("action"): action_pressed()
	
	if check_state():
		animate()

func check_state() -> bool:
	if state != STATE.KO and state != STATE.HIT and state != STATE.VICTORY:
		return true
	return false

func _physics_process(delta):
	if check_state():
		if check_snapped(1.0):
			snap_to_grid()
			change_pos.emit(global_position)
			
			hide_power_ups()
			
			if power_up_count > 0:
				match power_up_type:
					PowerUp.TYPE.ToyHammer:
						hammer.show()
					PowerUp.TYPE.BubbleGun:
						bubble_gun.show()
					PowerUp.TYPE.JackInTheBox:
						jack_in_the_box.show()
			
			var input = get_input()
			
			if input != Vector2.ZERO:
				if input.abs().x > input.abs().y:
					if input.x > 0:
						if not check_right.has_overlapping_bodies() or flatting_enemies(check_right):
							move(Vector2.RIGHT)
							
							state = STATE.WALK_RIGHT
					else:
						if not check_left.has_overlapping_bodies() or flatting_enemies(check_left):
							move(Vector2.LEFT)
							
							state = STATE.WALK_LEFT
				else:
					if input.y > 0:
						if not check_down.has_overlapping_bodies() or flatting_enemies(check_down):
							move(Vector2.DOWN)
							
							state = STATE.WALK_DOWN
					else:
						if not check_up.has_overlapping_bodies() or flatting_enemies(check_up):
							move(Vector2.UP)
							
							state = STATE.WALK_UP
			
			else:
				match state:
					STATE.WALK_RIGHT:
						state = STATE.IDLE_RIGHT
					
					STATE.IDLE_RIGHT:
						if flatting_enemies(check_right):
							move(Vector2.RIGHT)
							
							state = STATE.WALK_RIGHT
					
					STATE.WALK_LEFT:
						state = STATE.IDLE_LEFT
					
					STATE.IDLE_LEFT:
						if flatting_enemies(check_left):
							move(Vector2.LEFT)
							
							state = STATE.WALK_LEFT
					
					STATE.WALK_UP:
						state = STATE.IDLE_UP
					
					STATE.IDLE_UP:
						if flatting_enemies(check_up):
							move(Vector2.UP)
							
							state = STATE.WALK_UP
					
					STATE.WALK_DOWN:
						state = STATE.IDLE_DOWN
					
					STATE.IDLE_DOWN:
						if flatting_enemies(check_down):
							move(Vector2.DOWN)
							
							state = STATE.WALK_DOWN
		
		else:
			match state:
				STATE.WALK_RIGHT:
					flatting_enemies(check_right)
				STATE.WALK_LEFT:
					flatting_enemies(check_left)
				STATE.WALK_UP:
					flatting_enemies(check_up)
				STATE.WALK_DOWN:
					flatting_enemies(check_down)
	
	move_and_slide()


func move(direction: Vector2) -> void:
	var power_up_pos := direction * 8
	
	hammer.position = power_up_pos
	bubble_gun.position = power_up_pos
	jack_in_the_box.position = power_up_pos
	
	super(direction)


func flatting_enemies(area: Area2D) -> bool:
	if power_up_type == PowerUp.TYPE.ToyHammer and power_up_count > 0:
		for body in area.get_overlapping_bodies():
			if body is Enemy:
				power_up_count -= 1
				body.flat()
				return true
	
	return false


func get_input() -> Vector2:
	return Vector2(Input.get_axis("move_left", "move_right"), \
	Input.get_axis("move_up", "move_down"))

func action_pressed() -> void:
	if power_up_count > 0:
		match power_up_type:
			PowerUp.TYPE.BubbleGun:
				match state:
					STATE.IDLE_RIGHT, STATE.WALK_RIGHT:
						shoot_fire_bubble.emit(global_position, FireBubble.DIRECTION.Right)
					STATE.IDLE_LEFT, STATE.WALK_LEFT:
						shoot_fire_bubble.emit(global_position, FireBubble.DIRECTION.Left)
					STATE.IDLE_UP, STATE.WALK_UP:
						shoot_fire_bubble.emit(global_position, FireBubble.DIRECTION.Up)
					STATE.IDLE_DOWN, STATE.WALK_DOWN:
						shoot_fire_bubble.emit(global_position, FireBubble.DIRECTION.Down)
				
				power_up_count -= 1
			
			PowerUp.TYPE.JackInTheBox:
				put_jack_in_the_box.emit(global_position)
				
				power_up_count -= 1


func animate():
	match state:
		STATE.IDLE_LEFT:
			player_anim.play("IdleLeft")
			hammer.stop()
			bubble_gun.stop()
		STATE.IDLE_RIGHT:
			player_anim.play("IdleRight")
			hammer.stop()
			bubble_gun.stop()
		STATE.IDLE_UP:
			player_anim.play("IdleUp")
			hammer.stop()
			bubble_gun.stop()
		STATE.IDLE_DOWN:
			player_anim.play("IdleDown")
			hammer.stop()
			bubble_gun.stop()
		STATE.WALK_LEFT:
			player_anim.play("WalkLeft")
			hammer.play("Left")
			bubble_gun.play("Left")
		STATE.WALK_RIGHT:
			player_anim.play("WalkRight")
			hammer.play("Right")
			bubble_gun.play("Right")
		STATE.WALK_UP:
			player_anim.play("WalkUp")
			hammer.play("Up")
			bubble_gun.play("Up")
		STATE.WALK_DOWN:
			player_anim.play("WalkDown")
			hammer.play("Down")
			bubble_gun.play("Down")
		STATE.HIT:
			player_anim.play("Hit")
			hide_power_ups()
		STATE.KO:
			player_anim.play("KO")
			hide_power_ups()
		STATE.VICTORY:
			player_anim.play("Victory")
			hide_power_ups()


func hide_power_ups():
	hammer.hide()
	bubble_gun.hide()
	jack_in_the_box.hide()


func _on_colliding_body_entered(body: Node2D):
	if body is Enemy:
		if power_up_count == 0:
			if not is_invincibility:
				body.change_direction()
				hit()
		
		else:
			match power_up_type:
				PowerUp.TYPE.RollerSkate:
					if not is_invincibility:
						power_up_count = 0
						speed = ordinary_move_speed
						body.change_direction()
						hit()
				
				PowerUp.TYPE.ToyHammer:
					if check_snapped(1.0):
						body.change_direction()
						hit()
				
				_:
					if not is_invincibility:
						body.change_direction()
						hit()

func hit() -> void:
	snap_to_grid()

	previous_state = state
	state = STATE.HIT
	animate()

	apply_invincibiity()
	lose_live.emit()

func defeated() -> void:
	snap_to_grid()

	state = STATE.KO
	animate()

	apply_invincibiity()

func apply_invincibiity() -> void:
	is_invincibility = true
	invincibility_timer.start()

func _on_invincibility_timeout() -> void:
	is_invincibility = false


func pick_power_up(_type: PowerUp.TYPE, _count: int) -> void:
	power_up_type = _type
	power_up_count = _count
	
	speed = ordinary_move_speed
	match power_up_type:
		PowerUp.TYPE.RollerSkate:
			speed = increased_move_speed
	
	power_up_picked.emit()

func pick_toy(texture: Texture2D) -> void:
	toy.texture = texture
	picked_toy = true

func drop_toy() -> void:
	toy.texture = null
	picked_toy = false


func _on_animation_finished() -> void:
	match state:
		STATE.HIT:
			snap_to_grid()
			
			state = previous_state
			animate()


func slow_down() -> void:
	speed = slowing_move_speed
	slow_down_effect_timer.start()

func _on_slow_down_effect_timeout() -> void:
	speed = ordinary_move_speed


func victory(door_pos: Vector2) -> void:
	global_position = door_pos
	snap_to_grid()

	state = STATE.VICTORY
	animate()

	apply_invincibiity()
