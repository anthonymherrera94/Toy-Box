class_name Cards extends Area2D

enum ObjectsInto {
	Ballooon,
	BubbleGun,
	JackInTheBox,
	RollerSkate,
	ToyHammer,
	Bomb
}

var object_into: ObjectsInto

signal picked


func _on_body_entered(body: Node2D) -> void:
	if body is Aoy:
		picked.emit(object_into, global_position)
		queue_free()
