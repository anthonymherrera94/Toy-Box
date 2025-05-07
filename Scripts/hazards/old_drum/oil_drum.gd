class_name OilDrum extends StaticBody2D

@export var path_follow: PathFollow2D

@export var fireball_scene: PackedScene
var fireball: OilDrumFireball
var fireball_speed := 1

signal spawn_fireball


func _ready() -> void:
	if path_follow != null:
		_spawn_fireball()


func _spawn_fireball() -> void:
	var fb: OilDrumFireball = fireball_scene.instantiate()
	fb.hit.connect(_destroy_fireball)

	path_follow.add_child(fb)
	fireball = fb


func _destroy_fireball() -> void:
	if fireball != null: fireball.queue_free()


func _physics_process(delta: float) -> void:
	if path_follow != null:
		if path_follow.progress_ratio < 1:
			path_follow.progress += fireball_speed
		else:
			_destroy_fireball()
			_spawn_fireball()
			path_follow.progress = 0


func _on_spawn_fireballs_timeout() -> void:
	if path_follow == null:
		var offsets := [
			Vector2.UP,
			Vector2.DOWN,
			Vector2.LEFT,
			Vector2.RIGHT
		]
		
		spawn_fireball.emit(global_position + offsets.pick_random())
