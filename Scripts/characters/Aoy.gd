class_name Aoy extends Character

var map_offset: Vector2

var input := Vector2.ZERO
var move_speed := 80.0
var ordinary_move_speed := 80.0
var increased_move_speed := 120.0

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

var previous_anim: StringName
var is_invincibility := false

signal change_pos
signal lose_live

signal shoot_fire_bubble
signal put_jack_in_the_box


func _ready() -> void:
	move_speed = ordinary_move_speed


func _process(delta):
	input = get_input()
	
	if Input.is_action_just_pressed("action"): action_pressed()
	
	if state != STATE.KO and player_anim.animation != "Hitted":
		animate()
	

func _physics_process(delta):
	if state != STATE.KO:
		move()
		move_and_slide()
	

func get_input() -> Vector2:
	input.x = Input.get_axis("move_left", "move_right")
	input.y = Input.get_axis("move_up", "move_down")
	return input

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

func move():
	var snapped_pos = position.snapped(Vector2(16, 16))
	
	if position.distance_to(snapped_pos) < 1:
		change_pos.emit(position)
		position = snapped_pos
		velocity = Vector2.ZERO
		
		if power_up_count > 0:
			hide_power_ups()
			
			match power_up_type:
				PowerUp.TYPE.ToyHammer:
					hammer.show()
				PowerUp.TYPE.BubbleGun:
					bubble_gun.show()
				PowerUp.TYPE.JackInTheBox:
					jack_in_the_box.show()
				PowerUp.TYPE.RollerSkate:
					move_speed = increased_move_speed
		else:
			hide_power_ups()
		
		if input != Vector2.ZERO:
			if input.abs().x > input.abs().y:
				if input.x > 0:
					if not check_right.has_overlapping_bodies():
						var power_up_pos := Vector2.RIGHT * 8
						
						hammer.position = power_up_pos
						bubble_gun.position = power_up_pos
						jack_in_the_box.position = power_up_pos
						
						velocity = Vector2.RIGHT * move_speed
						
						state = STATE.WALK_RIGHT
				else:
					if not check_left.has_overlapping_bodies():
						var power_up_pos := Vector2.LEFT * 8
						
						hammer.position = power_up_pos
						bubble_gun.position = power_up_pos
						jack_in_the_box.position = power_up_pos
						
						velocity = Vector2.LEFT * move_speed
						
						state = STATE.WALK_LEFT
			else:
				if input.y > 0:
					if not check_down.has_overlapping_bodies():
						var power_up_pos := Vector2.DOWN * 8
						
						hammer.position = power_up_pos
						bubble_gun.position = power_up_pos
						jack_in_the_box.position = power_up_pos
						
						velocity = Vector2.DOWN * move_speed
						
						state = STATE.WALK_DOWN
				else:
					if not check_up.has_overlapping_bodies():
						var power_up_pos := Vector2.UP * 8
						
						hammer.position = power_up_pos
						bubble_gun.position = power_up_pos
						jack_in_the_box.position = power_up_pos
						
						velocity = Vector2.UP * move_speed
						
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
	
	else:
		match state:
			STATE.WALK_RIGHT:
				velocity = Vector2.RIGHT * move_speed
			STATE.WALK_LEFT:
				velocity = Vector2.LEFT * move_speed
			STATE.WALK_UP:
				velocity = Vector2.UP * move_speed
			STATE.WALK_DOWN:
				velocity = Vector2.DOWN * move_speed


func animate():
	if velocity != Vector2.ZERO:
		if velocity.abs().x > velocity.abs().y:
			if velocity.x < 0:
				player_anim.play("WalkLeft")
				
				hammer.play("Left")
				bubble_gun.play("Left")
			else:
				player_anim.play("WalkRight")
				
				hammer.play("Right")
				bubble_gun.play("Right")
		else:
			if velocity.y < 0:
				player_anim.play("WalkUp")
				
				hammer.play("Up")
				bubble_gun.play("Up")
			else:
				player_anim.play("WalkDown")
				
				hammer.play("Down")
				bubble_gun.play("Down")
	else:
		hammer.stop()
		bubble_gun.stop()
	
	match state:
		STATE.IDLE_LEFT:
			player_anim.play("IdleLeft")
		STATE.IDLE_RIGHT:
			player_anim.play("IdleRight")
		STATE.IDLE_UP:
			player_anim.play("IdleUp")
		STATE.IDLE_DOWN:
			player_anim.play("IdleDown")


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
						move_speed = ordinary_move_speed
						body.snap_to_grid()
						hitted()
				_:
					if not is_invincibility:
						body.snap_to_grid()
						hitted()


func hitted():
	snap_to_grid()
	collision_mask = 0
	
	previous_anim = player_anim.animation
	player_anim.play("Hitted")
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
	if player_anim.animation == "Hitted":
		player_anim.play(previous_anim)


func _on_invincibility_timeout() -> void:
	is_invincibility = false
	collision_mask = 1
