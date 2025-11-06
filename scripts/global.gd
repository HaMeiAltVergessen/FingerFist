extends Node

var highscores: Array[int] = []
var total_score: int = 0
var unlocked_levels: int = 1
var unlocked_gloves: int = 1
var coins: int = 0
var rounds_played: int = 0

var current_skin: String = "default"

# Skins mit Preis und Besitzstatus
var skins = {
	"default": {"cost": 0, "owned": true},
	"skin1": {"cost": 500, "owned": false}
}
# Zuordnung der Skins zu Texturen (Passe Pfade an deine Assets an)
const SKIN_TEXTURES = {
	"default": preload("res://assets/EigeneAssets/Finger 01.png"),
	"skin1": preload("res://assets/EigeneAssets/Finger 02.png")
}
const SAVE_FILE := "user://progression.save"
# Gibt die aktuelle Textur zurück
func get_current_skin_texture() -> Texture2D:
	if SKIN_TEXTURES.has(current_skin):
		return SKIN_TEXTURES[current_skin]
	else:
		return SKIN_TEXTURES["default"]

# Wird am Ende jeder Runde aufgerufen
func add_score(score: int) -> void:
	total_score += score
	coins += score / 10        # zuerst Münzen aktualisieren
	highscores.append(score)
	highscores.sort()
	highscores.reverse()
	_check_unlocks()
	rounds_played += 1
	save_progress()            # danach speichern


# Prüft Freischaltungen
func _check_unlocks() -> void:
	if total_score >= 100 and unlocked_levels < 2:
		unlocked_levels = 2
	if total_score >= 2500 and unlocked_levels < 3:
		unlocked_levels = 3

	if total_score >= 1500 and unlocked_gloves < 2:
		unlocked_gloves = 2
	if total_score >= 3000 and unlocked_gloves < 3:
		unlocked_gloves = 3


# Speichert alle relevanten Daten persistent
func save_progress() -> void:
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		var data = {
			"coins": coins,
			"skins": skins,
			"current_skin": current_skin,
			"highscores": highscores,
			"unlocked_levels": unlocked_levels,
			"total_score": total_score,
			"unlocked_gloves": unlocked_gloves,
			"rounds_played": rounds_played
		}
		file.store_var(data)
		file.close()


# Lädt den Speicherstand (z. B. im _ready() vom Hauptmenü)
func load_progress() -> void:
	if not FileAccess.file_exists(SAVE_FILE):
		return

	var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
	if not file:
		return

	var data = file.get_var()
	file.close()

	# Defensive: prüfen und nur übernehmen, wenn Typen passen
	coins = int(data.get("coins", 0))

	var loaded_skins = data.get("skins", null)
	if typeof(loaded_skins) == TYPE_DICTIONARY:
		skins = loaded_skins
	else:
		# Falls alte/corrupte Daten (z.B. String statt Dictionary), setze Defaults
		print("Warnung: gespeicherte 'skins' Daten ungültig — lade Defaults")
		skins = {
			"default": {"cost": 0, "owned": true},
			"skin1": {"cost": 500, "owned": false}
		}
		# optional: sofort neu speichern, um alten Save zu reparieren
		save_progress()

	current_skin = String(data.get("current_skin", current_skin))
	highscores = data.get("highscores", [])
	unlocked_levels = int(data.get("unlocked_levels", 1))
	unlocked_gloves = int(data.get("unlocked_gloves", 1))
	total_score = int(data.get("total_score", 0))
	rounds_played = int(data.get("rounds_played", 0))
