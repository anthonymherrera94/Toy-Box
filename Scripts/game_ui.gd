class_name GameUI extends Control

@export_category("Scenes")
@export var life: PackedScene

@export_category("Nodes")
@export var score: Label
@export var lives: HBoxContainer


func set_score(_score: int) -> void:
	score.text = str(_score)

func set_lives(_lives: int) -> void:
	clear_lives()
	for i in range(_lives):
		var obj: TextureRect = life.instantiate()
		lives.add_child(obj)

func clear_lives() -> void:
	for i in lives.get_children():
		i.queue_free()
