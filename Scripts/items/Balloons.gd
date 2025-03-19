class_name Balloons extends Area2D

@export var balloon_anim: AnimatedSprite2D

enum BALLOON_TYPE{
	S,
	U,
	P,
	E,
	R
}

@export var balloon_type: BALLOON_TYPE

var is_popped := false

signal popped


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


func _on_body_entered(body: Node2D) -> void:
	if body is Aoy:
		match balloon_type:
			BALLOON_TYPE.S:
				balloon_anim.play("SPop")
			BALLOON_TYPE.U:
				balloon_anim.play("UPop")
			BALLOON_TYPE.P:
				balloon_anim.play("PPop")
			BALLOON_TYPE.E:
				balloon_anim.play("EPop")
			BALLOON_TYPE.R:
				balloon_anim.play("RPop")
		
		popped.emit()
		
		is_popped = true
	
func _on_animation_finished() -> void:
	if is_popped:
		queue_free()
