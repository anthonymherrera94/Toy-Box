class_name SnakesHill extends StaticBody2D

@export var snakes: Array[Snake]

@export var bite_delay_timer: Timer

var can_bite := true


func _ready() -> void:
	for snake in snakes:
		var snake_check_area: Area2D = snake.get_child(0)
		snake_check_area.body_entered.connect(_on_body_entered.bind(snake))


func _on_body_entered(body: Node2D, snake: Snake) -> void:
	if can_bite:
		if body is Aoy:
			if not body.is_invincibility:
				snake.push_snake()
				body.hit()
				
				can_bite = false
				bite_delay_timer.start()


func _on_bite_delay_timeout() -> void:
	can_bite = true
