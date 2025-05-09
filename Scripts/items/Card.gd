class_name Card extends Area2D

enum ObjectsInto {
	Balloon,
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
