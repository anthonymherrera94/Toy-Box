class_name Xob extends Area2D

var move_speed := 40.0
var input := Vector2.ZERO
@export var player_anim: AnimatedSprite2D

var target_pos := Vector2.ZERO


func _process(delta):
	animate()
	
func _physics_process(delta):
	move()
	
func move():
	input = global_position.direction_to(target_pos)
	
	translate(input * move_speed / 100)

func set_targer_pos(pos: Vector2):
	target_pos = pos

func animate():
	if input.x < 0:
		player_anim.play("WalkLeft")
	else:
		player_anim.play("WalkRight")


func _on_body_entered(body: Node2D) -> void:
	if body is Aoy:
		body.lose()
