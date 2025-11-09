extends Node2D

@onready var highscore_label: Label =$HighscoreLabel


func _ready() -> void:
		# === WICHTIG: global speichern (einmal) ===
	Global.load_progress()
	_update_highscore_list()

func _update_highscore_list() -> void:
	var text := "Highscores:\n"
	for i in range(min(10, Global.highscores.size())):
		text += "%d. %d\n" % [i + 1, Global.highscores[i]]
	highscore_label.text = text
		# === WICHTIG: global speichern (einmal) ===

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
