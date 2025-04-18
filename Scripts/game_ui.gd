class_name GameUI extends CanvasLayer

@export_category("Scenes")
@export var life: PackedScene

@export_category("Nodes")
@export var score: Label
@export var high_score: Label
@export var bonus: Label
@export var lives: HBoxContainer

@export_category("Balloons")
@export var balloon_s: TextureRect
@export var balloon_u: TextureRect
@export var balloon_p: TextureRect
@export var balloon_e: TextureRect
@export var balloon_r: TextureRect

var balloons: Dictionary


func _ready() -> void:
	balloons = {
		Balloons.TYPE.S: balloon_s,
		Balloons.TYPE.U: balloon_u,
		Balloons.TYPE.P: balloon_p,
		Balloons.TYPE.E: balloon_e,
		Balloons.TYPE.R: balloon_r
	}
	
	for i in balloons:
		balloons[i].hide()


func set_score(_up: int) -> void:
	score.text = str(_up)

func set_high_score(_score: int) -> void:
	high_score.text = str(_score)

func set_bonus_time(_time: int) -> void:
	bonus.text = str(_time)

func set_lives(_lives: int) -> void:
	clear_lives()
	for i in range(_lives):
		var obj: TextureRect = life.instantiate()
		lives.add_child(obj)

func clear_lives() -> void:
	for i in lives.get_children():
		i.queue_free()

func pop_balloon(_type: Balloons.TYPE) -> void:
	balloons[_type].show()
