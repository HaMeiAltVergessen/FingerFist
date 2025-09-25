extends Control

@onready var start_button: Button = $StartButton
@onready var highscore_button: Button = $HighscoreButton
@onready var quit_button: Button = $QuitButton

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	highscore_button.pressed.connect(_on_highscore_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_highscore_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/HighscoreScreen.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
