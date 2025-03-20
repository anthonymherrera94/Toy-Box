class_name Enemy extends Character

enum TYPE {
	Tic,
	Tac,
	Toe
}

var map_offset: Vector2

var move_speed := 60.0
var input := Vector2.ZERO
@export var player_anim: AnimatedSprite2D
@export var navigation: NavigationAgent2D

@export var type: TYPE

signal defeated


func _process(delta):
	animate()
	
func _physics_process(delta):
	move()
	move_and_slide()
	
func move():
	if navigation.is_navigation_finished():
		return
	
	var next_path_pos := navigation.get_next_path_position()
	next_path_pos = next_path_pos.snapped(Vector2(16, 16))
	input = global_position.direction_to(next_path_pos)
	
	velocity = input * move_speed

func set_targer_pos(pos: Vector2):
	navigation.target_position = pos

func animate():
	if input.abs().x > input.abs().y:
		if input.x < 0.5:
			player_anim.play("WalkLeft")
		if input.x > 0.5:
			player_anim.play("WalkRight")
	else:
		if input.y < 0.5:
			player_anim.play("WalkUp")
		if input.y > 0.5:
			player_anim.play("WalkDown")


func defeat():
	defeated.emit(type)
	queue_free()
