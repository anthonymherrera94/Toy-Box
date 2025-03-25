class_name Aoy extends Character

var map_offset: Vector2

@export var ordinary_move_speed := 80.0
@export var increased_move_speed := 120.0

@export var player_anim: AnimatedSprite2D

@export var hammer: AnimatedSprite2D
@export var bubble_gun: AnimatedSprite2D
@export var jack_in_the_box: Sprite2D

@export var toy: Sprite2D

@export var invincibility_timer: Timer

var picked_toy := false
var picked_key := false

var power_up_count := 0
var power_up_type: PowerUp.TYPE

var previous_state: STATE
var is_invincibility := false

signal change_pos
signal lose_live

signal shoot_fire_bubble
signal put_jack_in_the_box


func _ready() -> void:
	speed = ordinary_move_speed


func _process(delta):
	if Input.is_action_just_pressed("action"): action_pressed()
	
	if state != STATE.KO and player_anim.animation != "Hitted":
		animate()
	

func _physics_process(delta):
	if state != STATE.KO:
		if check_snapped(1.0):
			snap_to_grid()
			change_pos.emit(position)
			
			hide_power_ups()
			
			if power_up_count > 0:
				match power_up_type:
					PowerUp.TYPE.ToyHammer:
						hammer.show()
					PowerUp.TYPE.BubbleGun:
						bubble_gun.show()
					PowerUp.TYPE.JackInTheBox:
						jack_in_the_box.show()
					PowerUp.TYPE.RollerSkate:
						speed = increased_move_speed
			
			var input = get_input()
			
			if input != Vector2.ZERO:
				if input.abs().x > input.abs().y:
					if input.x > 0:
						if not check_right.has_overlapping_bodies():
							var power_up_pos := Vector2.RIGHT * 8
							
							hammer.position = power_up_pos
							bubble_gun.position = power_up_pos
							jack_in_the_box.position = power_up_pos
							
							move(Vector2.RIGHT)
							
							state = STATE.WALK_RIGHT
					else:
						if not check_left.has_overlapping_bodies():
							var power_up_pos := Vector2.LEFT * 8
							
							hammer.position = power_up_pos
							bubble_gun.position = power_up_pos
							jack_in_the_box.position = power_up_pos
							
							move(Vector2.LEFT)
							
							state = STATE.WALK_LEFT
				else:
					if input.y > 0:
						if not check_down.has_overlapping_bodies():
							var power_up_pos := Vector2.DOWN * 8
							
							hammer.position = power_up_pos
							bubble_gun.position = power_up_pos
							jack_in_the_box.position = power_up_pos
							
							move(Vector2.DOWN)
							
							state = STATE.WALK_DOWN
					else:
						if not check_up.has_overlapping_bodies():
							var power_up_pos := Vector2.UP * 8
							
							hammer.position = power_up_pos
							bubble_gun.position = power_up_pos
							jack_in_the_box.position = power_up_pos
							
							move(Vector2.UP)
							
							state = STATE.WALK_UP
			
			else:
				match state:
					STATE.WALK_RIGHT:
						state = STATE.IDLE_RIGHT
					STATE.WALK_LEFT:
						state = STATE.IDLE_LEFT
					STATE.WALK_UP:
						state = STATE.IDLE_UP
					STATE.WALK_DOWN:
						state = STATE.IDLE_DOWN
		
		move_and_slide()
	

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


func hide_power_ups():
	hammer.hide()
	bubble_gun.hide()
	jack_in_the_box.hide()


func _on_colliding_body_entered(body: Node2D):
	if body is Enemy:
		if power_up_count == 0:
			if not is_invincibility:
				body.snap_to_grid()
				hitted()
		
		else:
			match power_up_type:
				PowerUp.TYPE.ToyHammer:
					power_up_count -= 1
					body.defeat()
				PowerUp.TYPE.RollerSkate:
					if not is_invincibility:
						power_up_count = 0
						speed = ordinary_move_speed
						body.snap_to_grid()
						hitted()
				_:
					if not is_invincibility:
						body.snap_to_grid()
						hitted()


func hitted():
	snap_to_grid()
	collision_mask = 0
	
	previous_state = state
	state = STATE.HITTED
	is_invincibility = true
	invincibility_timer.start()
	lose_live.emit()


func pick_toy(texture: Texture2D):
	toy.texture = texture
	picked_toy = true

func drop_toy():
	toy.texture = null
	picked_toy = false


func _on_animation_finished() -> void:
	match state:
		STATE.HITTED:
			state = previous_state


func _on_invincibility_timeout() -> void:
	is_invincibility = false
	collision_mask = 1
