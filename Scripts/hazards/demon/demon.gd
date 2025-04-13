class_name Demon extends Area2D

@export var self_destruction_timer: Timer

signal split_fireball


func _on_split_fireball_timeout() -> void:
	split_fireball.emit(global_position)
	self_destruction_timer.start()


func _on_self_destruction_timeout() -> void:
	queue_free()
