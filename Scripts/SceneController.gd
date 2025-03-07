class_name SceneController extends Node2D

@export var walls: TileMapLayer
var map_offset: Vector2

var aoy: Aoy
var enemies: Array[Enemy]


func _ready() -> void:
	if walls != null:
		map_offset = walls.position
		walls.hide()
	
	for i in get_children():
		if i is Aoy:
			i.map_offset = map_offset
			i.change_pos.connect(_on_aoy_change_pos)
			aoy = i
		if i is Enemy:
			i.map_offset = map_offset
			enemies.append(i)


func _on_aoy_change_pos(pos: Vector2) -> void:
	for i in enemies:
		i.set_targer_pos(pos)
