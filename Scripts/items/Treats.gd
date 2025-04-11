class_name Treats extends Area2D

@export var treat_anim: AnimatedSprite2D

enum TYPE {
	Candy,
	CandyCane,
	ChocolateBar,
	IceCream,
	Cake
}

@export var treat_type: TYPE

signal picked


func _ready():
	set_type()
	
func set_type():
	match treat_type:
		TYPE.Candy:
			treat_anim.play("Candy")
		TYPE.CandyCane:
			treat_anim.play("CandyCane")
		TYPE.ChocolateBar:
			treat_anim.play("ChocolateBar")
		TYPE.IceCream:
			treat_anim.play("IceCream")
		TYPE.Cake:
			treat_anim.play("Cake")


func _on_body_entered(body: Node2D) -> void:
	if body is Aoy:
		picked.emit()
		queue_free()
