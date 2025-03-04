class_name Menu extends CanvasLayer

@export var title_anim: AnimatedSprite2D
@export var player: AnimatedSprite2D
@export var player_run: AnimationPlayer

@export var scene: PackedScene


func _ready():
	title_anim.play("idle") 


func _on_animated_sprite_2d_animation_finished():
	player.play("right")
	player_run.play("start_run")

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		Globals.fade_in(scene)
