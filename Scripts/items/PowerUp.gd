class_name PowerUp extends Area2D

@export var power_up_anim: AnimatedSprite2D

enum TYPE {
	BubbleGun,
	JackInTheBox,
	RollerSkate,
	ToyHammer
}

@export var power_up_type: TYPE


func _ready():
	set_type()
	
func set_type():
	match power_up_type:
		TYPE.BubbleGun:
			power_up_anim.play("BubbleGun")
		TYPE.JackInTheBox:
			power_up_anim.play("JackInTheBox")
			power_up_anim.position.y -= 8
		TYPE.RollerSkate:
			power_up_anim.play("RollerSkate")
		TYPE.ToyHammer:
			power_up_anim.play("ToyHammer")


func _on_body_entered(body: Node2D) -> void:
	if body is Aoy:
		match power_up_type:
			TYPE.ToyHammer:
				body.power_up_count = 3
			TYPE.BubbleGun:
				body.power_up_count = 3
			TYPE.RollerSkate:
				body.power_up_count = 1
			TYPE.JackInTheBox:
				body.power_up_count = 1
		
		body.power_up_type = power_up_type
		
		queue_free()
