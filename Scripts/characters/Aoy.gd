class_name Aoy extends Character

var map_offset: Vector2

var move_speed := 80.0
var input := Vector2.ZERO

@export var player_anim: AnimatedSprite2D
@export var toy: Sprite2D

@export_category("Checkers")
@export var check_left: Area2D
@export var check_right: Area2D
@export var check_up: Area2D
@export var check_down: Area2D

var picked_toy := false
var picked_key := false

signal change_pos
signal restart


func _process(delta):
	input = get_input()
	if state != STATE.KO:
		animate()
	
func _physics_process(delta):
	if state != STATE.KO:
		move()
		move_and_slide()
	
func get_input() -> Vector2:
	input.x = Input.get_axis("move_left", "move_right")
	input.y = Input.get_axis("move_up", "move_down")
	return input

func move():
	var snapped_pos = position.snapped(Vector2(16, 16))
	
	if position.distance_to(snapped_pos) < 1:
		change_pos.emit(position)
		position = snapped_pos
		velocity = Vector2.ZERO
		
		if input != Vector2.ZERO:
			if input.abs().x > input.abs().y:
				if input.x > 0:
					if not check_right.has_overlapping_bodies():
						velocity = Vector2.RIGHT * move_speed
				else:
					if not check_left.has_overlapping_bodies():
						velocity = Vector2.LEFT * move_speed
			else:
				if input.y > 0:
					if not check_down.has_overlapping_bodies():
						velocity = Vector2.DOWN * move_speed
				else:
					if not check_up.has_overlapping_bodies():
						velocity = Vector2.UP * move_speed


func animate():
	if velocity != Vector2.ZERO:
		if velocity.abs().x > velocity.abs().y:
			if velocity.x < 0:
				player_anim.play("WalkLeft")
				state = STATE.WALK_LEFT
			else:
				player_anim.play("WalkRight")
				state = STATE.WALK_RIGHT
		else:
			if velocity.y < 0:
				player_anim.play("WalkUp")
				state = STATE.WALK_UP
			else:
				player_anim.play("WalkDown")
				state = STATE.WALK_DOWN
	else:
		match state:
			STATE.WALK_LEFT:
				player_anim.play("IdleLeft")
				state = STATE.IDLE_LEFT
			STATE.WALK_RIGHT:
				player_anim.play("IdleRight")
				state = STATE.IDLE_RIGHT
			STATE.WALK_UP:
				player_anim.play("IdleUp")
				state = STATE.IDLE_UP
			STATE.WALK_DOWN:
				player_anim.play("IdleDown")
				state = STATE.IDLE_DOWN


func _on_colliding_body_entered(body: Node2D):
	if body is Enemy:
		lose()

func lose():
	if state != STATE.KO:
		player_anim.play("KO")
		state = STATE.KO
		restart_level()

func restart_level():
	restart.emit()


func pick_toy(texture: Texture2D):
	toy.texture = texture
	picked_toy = true

func drop_toy():
	toy.texture = null
	picked_toy = false
