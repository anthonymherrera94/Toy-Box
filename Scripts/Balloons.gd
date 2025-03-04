class_name Balloons extends Area2D

@export var balloon_anim: AnimatedSprite2D

enum BALLOON_TYPE{
	S,
	U,
	P,
	E,
	R
}

@export var balloon_type:BALLOON_TYPE

func _ready():
	set_type()
	
func set_type():
	match balloon_type:
		BALLOON_TYPE.S:
			balloon_anim.play("S")
		BALLOON_TYPE.U:
			balloon_anim.play("U")
		BALLOON_TYPE.P:
			balloon_anim.play("P")
		BALLOON_TYPE.E:
			balloon_anim.play("E")
		BALLOON_TYPE.R:
			balloon_anim.play("R")
