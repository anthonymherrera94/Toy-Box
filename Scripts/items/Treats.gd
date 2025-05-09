class_name Treat extends Area2D

@export var treat_anim: AnimatedSprite2D

enum TYPE {
	Candy,
	CandyCane,
	ChocolateBar,
	IceCream,
	Cake
}

@export var type: TYPE

signal picked


func _ready():
	hide()
	

func set_type(type_: Treat.TYPE):
	type = type_
	
	match type:
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
