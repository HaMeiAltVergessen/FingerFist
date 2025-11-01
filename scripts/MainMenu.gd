extends Control

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_highscore_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/HighscoreScreen.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_option_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Options.tscn")


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Credits.tscn")
