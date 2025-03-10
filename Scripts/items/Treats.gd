class_name Treats extends Area2D

@export var treat_anim: AnimatedSprite2D

enum TREAT_TYPE{
	Candy,
	CandyCane,
	ChocolateBar,
	IceCream,
	Cake
}

@export var treat_type: TREAT_TYPE

signal picked


func _ready():
	set_type()
	
func set_type():
	match treat_type:
		TREAT_TYPE.Candy:
			treat_anim.play("Candy")
		TREAT_TYPE.CandyCane:
			treat_anim.play("CandyCane")
		TREAT_TYPE.ChocolateBar:
			treat_anim.play("ChocolateBar")
		TREAT_TYPE.IceCream:
			treat_anim.play("IceCream")
		TREAT_TYPE.Cake:
			treat_anim.play("Cake")


func _on_body_entered(body: Node2D) -> void:
	if body is Aoy:
		picked.emit()
		queue_free()
