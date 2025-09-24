extends Node2D

@onready var sprite = $AnimatedSprite2D
var anim_names = []

func _ready():
	anim_names = sprite.sprite_frames.get_animation_names()

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		sprite.global_position = get_global_mouse_position()
		var random_anim = anim_names[randi() % anim_names.size()]
		sprite.play(random_anim)
