class_name PowerUp extends Area2D

@export var power_up_anim: AnimatedSprite2D

enum POWER_UP_TYPE{
	BubbleGun,
	JackInTheBox,
	RollerSkate,
	ToyHammer
}

@export var power_up_type: POWER_UP_TYPE


func _ready():
	set_type()
	
func set_type():
	match power_up_type:
		POWER_UP_TYPE.BubbleGun:
			power_up_anim.play("BubbleGun")
		POWER_UP_TYPE.JackInTheBox:
			power_up_anim.play("JackInTheBox")
			power_up_anim.position.y -= 8
		POWER_UP_TYPE.RollerSkate:
			power_up_anim.play("RollerSkate")
		POWER_UP_TYPE.ToyHammer:
			power_up_anim.play("ToyHammer")


func _on_body_entered(body: Node2D) -> void:
	if body is Aoy:
		queue_free()
