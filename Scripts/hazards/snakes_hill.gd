class_name SnakesHill extends StaticBody2D

@export var snakes: Node2D

@export var bite_delay_timer: Timer

var current_snake := 0


func _on_bite_delay_timeout() -> void:
	var snake: Snake = snakes.get_child(current_snake)
	snake.push_snake()

	if current_snake + 1 < snakes.get_child_count():
		current_snake += 1
	else:
		current_snake = 0
