class_name Demon extends Area2D

@export var self_destruction_timer: Timer

@export var check_left: Area2D
@export var check_right: Area2D
@export var check_up: Area2D
@export var check_down: Area2D

signal split_fireball


func _on_split_fireball_timeout() -> void:
	var fireball_direction: Fireball.Direction
	
	while (true):
		fireball_direction = randi() % Fireball.Direction.size()
		
		match fireball_direction:
			Fireball.Direction.Left:
				if check_place(check_left):
					break
			Fireball.Direction.Right:
				if check_place(check_right):
					break
			Fireball.Direction.Up:
				if check_place(check_up):
					break
			Fireball.Direction.Down:
				if check_place(check_down):
					break
	
	split_fireball.emit(global_position, fireball_direction)
	self_destruction_timer.start()


func check_place(check_area: Area2D) -> bool:
	var bodies := check_area.get_overlapping_bodies()
	
	for body in bodies:
		if body is Aoy:
			return true
	
	if check_area.has_overlapping_bodies(): return false
	else: return true


func _on_self_destruction_timeout() -> void:
	queue_free()
