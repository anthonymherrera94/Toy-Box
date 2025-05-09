class_name RandomChangeDirectionCharacter extends Character

var possible_directions := [
	Vector2.RIGHT,
	Vector2.LEFT,
	Vector2.UP,
	Vector2.DOWN
]

var change_direction_delay := 0


func change_direction() -> void:
	snap_to_grid()
	change_direction_delay = 0

func change_direction_to_random() -> Vector2:
	return possible_directions.pick_random()
