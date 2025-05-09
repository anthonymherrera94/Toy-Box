class_name CheatConsole extends Control

const _CHANGE_LEVEL_OUTPUT := "A level changed to %s"

@export var _input: LineEdit
@export var _output: VBoxContainer

signal change_level


func _on_input_text_submitted(text: String) -> void:
	var command := text.split(" ")
	
	if command[0] == "go" and command[1] == "to":
		match command[2]:
			"toy1":
				change_level.emit(0)
				create_output(_CHANGE_LEVEL_OUTPUT % ["Toy Town 1"])
			"toy2":
				change_level.emit(1)
				create_output(_CHANGE_LEVEL_OUTPUT % ["Toy Town 2"])
			"toy3":
				change_level.emit(2)
				create_output(_CHANGE_LEVEL_OUTPUT % ["Toy Town 3"])
			"sweet1":
				change_level.emit(3)
				create_output(_CHANGE_LEVEL_OUTPUT % ["Sweet Lands 1"])
			"sweet2":
				change_level.emit(4)
				create_output(_CHANGE_LEVEL_OUTPUT % ["Sweet Lands 2"])
			"sweet3":
				change_level.emit(5)
				create_output(_CHANGE_LEVEL_OUTPUT % ["Sweet Lands 3"])
			"rainbow1":
				change_level.emit(6)
				create_output(_CHANGE_LEVEL_OUTPUT % ["Rainbow Heaven 1"])
			"rainbow2":
				change_level.emit(7)
				create_output(_CHANGE_LEVEL_OUTPUT % ["Rainbow Heaven 2"])
			"rainbow3":
				change_level.emit(8)
				create_output(_CHANGE_LEVEL_OUTPUT % ["Rainbow Heaven 3"])
			"arcade1":
				change_level.emit(9)
				create_output(_CHANGE_LEVEL_OUTPUT % ["Arcade Zone 1"])
			"arcade2":
				change_level.emit(10)
				create_output(_CHANGE_LEVEL_OUTPUT % ["Arcade Zone 2"])
			"arcade3":
				change_level.emit(11)
				create_output(_CHANGE_LEVEL_OUTPUT % ["Arcade Zone 3"])
			"xob1":
				change_level.emit(12)
				create_output(_CHANGE_LEVEL_OUTPUT % ["Xob's Party 1"])
			"xob2":
				change_level.emit(13)
				create_output(_CHANGE_LEVEL_OUTPUT % ["Xob's Party 2"])
			"xob3":
				change_level.emit(14)
				create_output(_CHANGE_LEVEL_OUTPUT % ["Xob's Party 3"])
			"final":
				change_level.emit(15)
				create_output(_CHANGE_LEVEL_OUTPUT % ["Final Battle"])
			_:
				create_output("You couldn't change a level! Because that level doesn't exist.")
	
	else:
		if text == "immortal":
			Globals.aoy_invincibility = true
			create_output("Aoy is immortal now!")
		elif text == "mortal":
			Globals.aoy_invincibility = false
			create_output("Aoy is mortal now!")
		else:
			create_output("I don't know this command...")
	
	_input.clear()


func create_output(text: String) -> void:
	var label := Label.new()
	label.text = text
	_output.add_child(label)
