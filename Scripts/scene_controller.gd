class_name SceneController extends Node2D

@export var walls: TileMapLayer
@export var game_ui: GameUI

var map_offset: Vector2

# Map size in tiles. You can see it just select the "Walls" node, then
# moving cursor to the tile at the left-top corner, then to
# the right-bottom corner.
@export var map_size: Rect2i

@export var next_level: PackedScene

var aoy: Aoy
var enemies: Array[Enemy]

var current_treat: Treats.TREAT_TYPE = 0

#The spawn delay for treats in seconds
const treats_spawn_delay := 5.0

var treats_spawn_timer := Timer.new()
var treat: Treats
var is_treat_picked := false

var score := 0


func _ready() -> void:
	if walls != null:
		map_offset = walls.position
		walls.hide()
	
	add_child(treats_spawn_timer)
	treats_spawn_timer.timeout.connect(_spawn_treat)
	treats_spawn_timer.start(treats_spawn_delay)
	
	for i in get_children():
		if i is Aoy:
			i.map_offset = map_offset
			i.change_pos.connect(_on_aoy_change_pos)
			aoy = i
		if i is Enemy:
			i.map_offset = map_offset
			enemies.append(i)
	
	game_ui.show()
	game_ui.set_score(0)

func _spawn_treat() -> void:
	if not is_treat_picked:
		current_treat = 0
	is_treat_picked = false
	
	if treat != null: treat.queue_free()
	
	var obj: Treats = Globals.treat.instantiate()
	obj.treat_type = current_treat
	obj.picked.connect(_on_treat_picked)
	
	var obj_pos: Vector2i
	
	while true:
		obj_pos = Vector2i(randi_range(map_size.position.x + 1, map_size.size.x - 2), \
		randi_range(map_size.position.y + 1, map_size.size.y - 2))
		
		if walls.get_cell_atlas_coords(obj_pos - Vector2i.ONE) == Vector2i(1, 0):
			break
	
	obj_pos *= 16
	
	obj.position = obj_pos
	
	add_child(obj)
	obj.set_type()
	
	treat = obj

func _on_aoy_change_pos(pos: Vector2) -> void:
	for i in enemies:
		i.set_targer_pos(pos)


func _on_treat_picked() -> void:
	match current_treat:
		Treats.TREAT_TYPE.Candy:
			add_score(500)
		Treats.TREAT_TYPE.CandyCane:
			add_score(1000)
		Treats.TREAT_TYPE.ChocolateBar:
			add_score(2000)
		Treats.TREAT_TYPE.IceCream:
			add_score(3000)
		Treats.TREAT_TYPE.Cake:
			add_score(5000)
	
	if current_treat < Treats.TREAT_TYPE.size() - 1:
		current_treat += 1
	else:
		current_treat = 0
	
	is_treat_picked = true


func add_score(points: int) -> void:
	score += points
	game_ui.set_score(score)
