extends Node

const CONF_PATH := "user://Config.ini"

const HIGH_SCORE := "High Score: "

var config: Dictionary


	
func _ready() -> void:
	_read_config()

func _read_config() -> void:
	if FileAccess.file_exists(CONF_PATH):
		var file := FileAccess.open(CONF_PATH, FileAccess.READ)
		config = file.get_var()
		file.close()
	else:
		_create_config()

func _create_config() -> void:
	config[HIGH_SCORE] = 0
	_write_config()

func _write_config() -> void:
	var file := FileAccess.open(CONF_PATH, FileAccess.WRITE)
	file.store_var(config)
	file.close()
	


func get_high_score() -> int: return config[HIGH_SCORE]

func set_high_score (score: int) -> void:
	config[HIGH_SCORE] = score
	_write_config()
