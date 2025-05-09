class_name Balloons extends Area2D

@export var balloon_anim: AnimatedSprite2D

enum TYPE{
	S,
	U,
	P,
	E,
	R,
	Nothing
}

@export var balloon_type: TYPE

var is_popped := false

signal popped


func _ready():
	set_type()

func set_type():
	match balloon_type:
		TYPE.S:
			balloon_anim.play("S")
		TYPE.U:
			balloon_anim.play("U")
		TYPE.P:
			balloon_anim.play("P")
		TYPE.E:
			balloon_anim.play("E")
		TYPE.R:
			balloon_anim.play("R")
	


func _on_body_entered(body: Node2D) -> void:
	if body is Aoy:
		pop_animation()
		
		popped.emit(balloon_type)


func pop_animation() -> void:
	match balloon_type:
		TYPE.S:
			balloon_anim.play("SPop")
		TYPE.U:
			balloon_anim.play("UPop")
		TYPE.P:
			balloon_anim.play("PPop")
		TYPE.E:
			balloon_anim.play("EPop")
		TYPE.R:
			balloon_anim.play("RPop")
	
	is_popped = true

func _on_animation_finished() -> void:
	if is_popped:
		queue_free()
