extends Node

var highscores: Array[int] = []
var total_score: int = 0
var unlocked_levels: int = 1
var unlocked_gloves: int = 1

const SAVE_FILE = "user://progression.save"

func add_score(score: int) -> void:
	total_score += score
	Global.add_score(score)
	highscores.sort()
	highscores.reverse()
	_check_unlocks()
	save_progress()

func _check_unlocks() -> void:
	# Level-Progression
	if total_score >= 1000 and unlocked_levels < 2:
		unlocked_levels = 2
	if total_score >= 2500 and unlocked_levels < 3:
		unlocked_levels = 3

	# Handschuhe
	if total_score >= 1500 and unlocked_gloves < 2:
		unlocked_gloves = 2
	if total_score >= 3000 and unlocked_gloves < 3:
		unlocked_gloves = 3

func save_progress() -> void:
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		file.store_var({
			"highscores": highscores,
			"total_score": total_score,
			"unlocked_levels": unlocked_levels,
			"unlocked_gloves": unlocked_gloves
		})

func load_progress() -> void:
	if FileAccess.file_exists(SAVE_FILE):
		var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
		if file:
			var data = file.get_var()
			highscores = data.get("highscores", [])
			total_score = data.get("total_score", 0)
			unlocked_levels = data.get("unlocked_levels", 1)
			unlocked_gloves = data.get("unlocked_gloves", 1)
