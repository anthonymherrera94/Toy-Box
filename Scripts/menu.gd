extends CanvasLayer


@onready var title_anim = $AnimatedSprite2D
@onready var player = $Player
@export var scene : PackedScene

func _ready():
	title_anim.play("idle") 


func _on_animated_sprite_2d_animation_finished():
	player.play("right")
	$PlayerRun.play("start_run")

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		Globals.fade_in(scene)
