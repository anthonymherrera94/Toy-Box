class_name GameStats extends Node

var main: SceneController
var spawning: SceneControllerSpawning
var objects_holder: SceneControllerObjectsHolder

var game_ui: GameUI

var score := 0
var lives := 3
var bonus_time := 10000

var power_up_score := 0

var current_balloon: Balloons.TYPE
var current_treat: Treat.TYPE

var toys_left := 0


func initialize() -> void:
	game_ui.show()
	game_ui.set_score(score)
	game_ui.set_lives(lives)


func add_score(points: int) -> void:
	score += points
	game_ui.set_score(score)

func earn_score_from_enemy() -> void:
	add_score(power_up_score)
	match power_up_score:
		400:
			power_up_score = 800
		800:
			power_up_score = 1600

func _on_bonus_time_tick() -> void:
	if bonus_time > 0:
		bonus_time -= 10
	else:
		if objects_holder.xob == null: spawning.spawn_xob()
	
	game_ui.set_bonus_time(bonus_time)


func set_popped_balloon(type: Balloons.TYPE) -> void:
	game_ui.pop_balloon(type)

func _on_lose_live() -> void:
	if lives > 0:
		lives -= 1
		game_ui.set_lives(lives)
		
	else:
		objects_holder.aoy.defeated()
		main.restart.emit()
