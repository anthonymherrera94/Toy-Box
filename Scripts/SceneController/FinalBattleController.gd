class_name FinalBattleController extends Node

@export var main: SceneController

@export var xob: XobInTrueForm


func _ready() -> void:
	main.is_it_final_battle = true
	xob.target_reached.connect(_change_xob_destination)
	_change_xob_destination()

func _on_change_xob_destination_timeout() -> void:
	_change_xob_destination()

func _change_xob_destination() -> void:
	randomize()
	xob.change_target_pos(Vector2(
		randf_range(main.map_size.position.x * 16, main.map_size.size.x * 16), \
		randf_range(main.map_size.position.y * 16, main.map_size.size.y * 16)
	))
