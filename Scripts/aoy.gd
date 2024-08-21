extends Character

@onready var move_speed = 80
var input = Vector2.ZERO
@onready var player_anim = $AnimatedSprite2D

func _process(delta):
	input = get_input()
	animate()
	
func _physics_process(delta):
	move()
	move_and_slide()
	
func get_input():
	input.x = Input.get_axis("move_left","move_right")
	input.y = Input.get_axis("move_up","move_down")
	return input

func move():
	velocity = input * move_speed
	if velocity.x != 0 and velocity.y !=0:
		velocity = Vector2.ZERO

func animate():
	if Input.is_action_pressed("move_left") and input.x !=0:
		player_anim.play("WalkLeft")
	if Input.is_action_pressed("move_right") and input.x !=0:
		player_anim.play("WalkRight")
	if Input.is_action_just_released("move_left") and input.x == 0:
		player_anim.play("IdleLeft")
	if Input.is_action_just_released("move_right") and input.x == 0:
		player_anim.play("IdleRight")
	if Input.is_action_pressed("move_up") and input.y != 0:
		player_anim.play("WalkUp")
	if Input.is_action_pressed("move_down") and input.y != 0:
		player_anim.play("WalkDown")
	if Input.is_action_just_released("move_up") and input.y == 0:
		player_anim.play("IdleUp")
	if Input.is_action_just_released("move_down") and input.y == 0:
		player_anim.play("IdleDown")
