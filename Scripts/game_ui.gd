class_name GameUI extends CanvasLayer

@export var score_label: Label
@export var score_txt: String


func set_score(score: int) -> void:
	score_label.text = score_txt + str(score)
