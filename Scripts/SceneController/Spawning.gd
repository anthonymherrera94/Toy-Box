class_name SceneControllerSpawning extends Node

enum XobSpawnSide { Top, Bottom, Left, Right }

var main: SceneController
var objects_holder: SceneControllerObjectsHolder
var game_stats: GameStats

var map_offset: Vector2
var map_size: Rect2i

var balloon: PackedScene
var treat: PackedScene
var key: PackedScene
var power_up: PackedScene
var gemstone: PackedScene
var enemy_respawn_anim: PackedScene
var tic: PackedScene
var tac: PackedScene
var toe: PackedScene
var fire_bubble: PackedScene
var jack_in_the_box: PackedScene
var xob: PackedScene
var syrup: PackedScene
var bomb: PackedScene
var explosion: PackedScene
var demon: PackedScene
var fireball: PackedScene
var firework: PackedScene

var is_balloon_spawned := false
var is_treat_spawned := false


#func spawn_toy(texture: Texture2D) -> void:
	#var obj: Toy = toy.instantiate()
	#obj.position = pick_random_pos()
	#main.get_parent().add_child.call_deferred(obj)
	#obj.set_sprite(texture)
	#game_stats.toys_left += 1

#func spawn_card() -> void:
	#var obj: Cards = card.instantiate()
	#
	#var object_into: Cards.ObjectsInto
	#if is_balloon_spawned == false:
		#object_into = Cards.ObjectsInto.Ballooon
		#is_balloon_spawned = true
	#else:
		#object_into = randi() % Cards.ObjectsInto.size()
		#while object_into == Cards.ObjectsInto.Ballooon:
			#object_into = randi() % Cards.ObjectsInto.size()
	#
	#obj.object_into = object_into
	#obj.picked.connect(main._on_card_picked)
	#obj.position = pick_random_pos()
	#main.get_parent().add_child.call_deferred.call_deferred(obj)

func spawn_balloon() -> void:
	if game_stats.current_balloon != Balloons.TYPE.Nothing:
		var obj: Balloons = balloon.instantiate()
		obj.balloon_type = game_stats.current_balloon
		obj.position = pick_random_pos()
		obj.popped.connect(main._on_balloon_popped)
		main.get_parent().add_child.call_deferred(obj)
		
		objects_holder.balloon = obj
		
		main.ballon_pop_delay.start()

#func spawn_treat() -> void:
	#if not is_treat_spawned:
		#var obj: Treats = treat.instantiate()
		#obj.treat_type = game_stats.current_treat
		#obj.position = pick_random_pos()
		#obj.picked.connect(main._on_treat_picked)
		#main.get_parent().add_child.call_deferred(obj)
		#
		#objects_holder.treat = obj
		#
		#main.treats_picked_delay.start()
		#
		#is_treat_spawned = true

func spawn_key() -> void:
	var obj: Key = key.instantiate()
	obj.picked.connect(main._on_key_picked)
	obj.position = pick_random_pos()
	main.get_parent().add_child.call_deferred(obj)

func spawn_power_up(type: PowerUp.TYPE) -> void:
	var obj: PowerUp = power_up.instantiate()
	obj.power_up_type = type
	obj.position = pick_random_pos()
	main.get_parent().add_child.call_deferred(obj)

func spawn_gemstones() -> void:
	var segment := 0
	
	for x in range(map_size.position.x, map_size.size.x):
		for y in range(map_size.position.y, map_size.size.y):
			var obj_pos: Vector2i = Vector2i(x, y)
			
			if main.tiles.get_cell_atlas_coords(obj_pos - Vector2i.ONE) == Vector2i(1, 0) \
			and obj_pos.distance_to(objects_holder.toy_chest.global_position / 16) > 2.0 \
			and segment == 0:
				var obj: Gemstone = gemstone.instantiate()
				obj.picked.connect(main._on_gemstone_picked)
				
				obj.position = main.tiles.map_to_local(obj_pos) - Vector2.ONE * 8
				
				main.get_parent().add_child.call_deferred(obj)
				objects_holder.gemstones.append(obj)
			
			if segment < 3: segment += 1
			else: segment = 0
	
	main.bonus_round_timer.start()


func spawn_fire_bubble(pos: Vector2, direction: FireBubble.DIRECTION) -> void:
	var obj: FireBubble = fire_bubble.instantiate()
	obj.direction = direction
	obj.position = pos
	main.get_parent().add_child.call_deferred(obj)

func spawn_jack_in_the_box(pos: Vector2) -> void:
	var obj: JackInTheBox = jack_in_the_box.instantiate()
	obj.position = pos
	main.get_parent().add_child.call_deferred(obj)


func respawn_enemy(type: Enemy.TYPE, spawn_pos: Vector2) -> void:
	var anim: AnimatedSprite2D = enemy_respawn_anim.instantiate()
	anim.position = spawn_pos
	
	main.get_parent().add_child.call_deferred(anim)
	
	main.respawn_delay_timer.start(main.respawn_delay_timer.wait_time)
	await main.respawn_delay_timer.timeout
	
	var obj: Node2D
	
	match type:
		Enemy.TYPE.Tic:
			obj = tic.instantiate()
		Enemy.TYPE.Tac:
			obj = tac.instantiate()
		Enemy.TYPE.Toe:
			obj = toe.instantiate()
	
	obj.get_child(0).map_offset = map_offset
	obj.get_child(0).defeated.connect(main._on_enemy_defeated)
	obj.position = anim.position
	
	main.get_parent().add_child.call_deferred(obj)
	objects_holder.enemies.append(obj)
	
	anim.queue_free()

func spawn_xob() -> void:
	var obj: Xob = xob.instantiate()
	var side: XobSpawnSide = randi() % XobSpawnSide.size()
	
	match side:
		XobSpawnSide.Top:
			obj.position = Vector2(randf_range(map_size.position.x * 16, map_size.size.x * 16), \
			map_size.position.y * 16 - 2 * 16)
		XobSpawnSide.Bottom:
			obj.position = Vector2(randf_range(map_size.position.x * 16, map_size.size.x * 16), \
			map_size.size.y * 16 + 2 * 16)
		XobSpawnSide.Left:
			obj.position = Vector2(map_size.position.x * 16 - 2 * 16, \
			randf_range(map_size.position.y * 16, map_size.size.y * 16))
		XobSpawnSide.Right:
			obj.position = Vector2(map_size.size.x * 16 + 2 * 16, \
			randf_range(map_size.position.y * 16, map_size.size.y * 16))
	
	obj.position += map_offset
	
	main.get_parent().add_child.call_deferred(obj)
	
	objects_holder.xob = obj


func spawn_syrup() -> void:
	var obj: Syrup = syrup.instantiate()
	obj.position = pick_random_pos()
	main.get_parent().add_child.call_deferred(obj)


func spawn_bomb(pos: Vector2) -> void:
	var obj: Bomb = bomb.instantiate()
	obj.position = pos
	obj.explode.connect(main._on_bomb_explode)
	main.get_parent().add_child.call_deferred(obj)


func spawn_explosion(pos: Vector2) -> void:
	var obj: Explosion = explosion.instantiate()
	obj.type = Explosion.TYPE.Cross
	obj.position = pos
	main.get_parent().add_child.call_deferred(obj)
	
	spawn_explosion_by_side(pos, Vector2i.LEFT, Explosion.TYPE.Horizontal)
	spawn_explosion_by_side(pos, Vector2i.RIGHT, Explosion.TYPE.Horizontal)
	spawn_explosion_by_side(pos, Vector2i.UP, Explosion.TYPE.Vertical)
	spawn_explosion_by_side(pos, Vector2i.DOWN, Explosion.TYPE.Vertical)

func spawn_explosion_by_side(start_pos: Vector2i, side: Vector2i, type: Explosion.TYPE) -> void:
	var side_ := start_pos / 16 + side
	while main.tiles.get_cell_atlas_coords(side_ - Vector2i.ONE) == Vector2i(1, 0):
		var obj_: Explosion = explosion.instantiate()
		obj_.type = type
		
		obj_.position = main.tiles.map_to_local(side_) - Vector2.ONE * 8
		
		main.get_parent().add_child.call_deferred(obj_)
		
		side_ += side


func spawn_demon() -> void:
	var obj: Demon = demon.instantiate()
	obj.position = pick_random_pos()
	obj.split_fireball.connect(main._on_demon_split_fireball)
	main.get_parent().add_child.call_deferred(obj)

func spawn_fireball(pos: Vector2, direction: DemonFireball.Direction) -> void:
	var obj: DemonFireball = fireball.instantiate()
	obj.direction = direction
	obj.position = pos
	main.get_parent().add_child.call_deferred(obj)


func spawn_firework() -> void:
	var obj: Firework = firework.instantiate()
	obj.position = Vector2(randf_range(map_size.position.x * 16, map_size.size.x * 16), \
		randf_range(map_size.position.y * 16, map_size.size.y * 16) )
	main.get_parent().add_child.call_deferred(obj)


func pick_random_pos() -> Vector2:
	var obj_pos: Vector2i
	
	while true:
		obj_pos = Vector2i(randi_range(map_size.position.x + 1, map_size.size.x - 2), \
		randi_range(map_size.position.y + 1, map_size.size.y - 2))
		
		if main.tiles.get_cell_atlas_coords(obj_pos - Vector2i.ONE) == Vector2i(1, 0) \
		and obj_pos.distance_to(objects_holder.aoy.global_position / 16) > 2.0 \
		and obj_pos.distance_to(objects_holder.toy_chest.global_position / 16) > 2.0:
			break
	
	obj_pos = main.tiles.map_to_local(obj_pos) - Vector2.ONE * 8
	
	return obj_pos
