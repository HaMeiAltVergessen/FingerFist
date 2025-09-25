extends Node2D

@onready var end_screen: CanvasLayer = $EndScreen
@onready var pause_screen: CanvasLayer = $PauseScreen

@onready var continue_button: Button = $PauseScreen/ContinueButton
@onready var retry_button: Button = $EndScreen/RetryButton

@onready var pause_score_label: Label = $PauseScreen/PauseScoreLabel
@onready var next_round_time_label: Label = $PauseScreen/NextRoundTimeLabel
@onready var final_score_label: Label = $EndScreen/FinalScore
@onready var highscore_label: Label = $EndScreen/HighscoreLabel
@onready var timer_label: Label = $GameScreen/TimerLabel

@onready var game_timer: Timer = $GameTimer
@onready var box_sack: Sprite2D = $GameScreen/BoxSack
@onready var game_camera: Camera2D = $GameCamera

@onready var box_sound1: AudioStreamPlayer = $BoxSound1
@onready var box_sound2: AudioStreamPlayer = $BoxSound2
@onready var punch_sounds: Array[AudioStreamPlayer] = [
	$BoxPunch01,
	$BoxPunch02,
	$BoxPunch03,
	$BoxPunch04,
	$BoxPunch05,
	$BoxPunch06,
	$BoxPunch07,
	$BoxPunch08,
	$BoxPunch09,
	$BoxPunch10
]

var highscores: Array[int] = []
var score: int = 0
@warning_ignore("shadowed_global_identifier")
var round: int = 0
var rounds_total: int = 3
var round_durations: Array = []
var next_round_time: int = 0
var game_active: bool = false
var sack_stages: Array[Texture2D] = []  # Texturen für Schaden
var highscore: int = 0
var round_count: int = 0


func _ready() -> void:
	# Level je nach Progression laden
	match Global.unlocked_levels:
		1:
			$Background/BackgroundSprite.texture = load("res://assets/Free Pixel Art Forest/PNG/Background layers/Layer_0002_7.png")
			box_sack.texture = load("res://assets/BoxSackBase.png")
		2:
			#$Background.texture = load("res://assets/bg_level2.png")
			box_sack.texture = load("res://assets/BoxSack2.png")
		3:
			#$Background.texture = load("res://assets/bg_level3.png")
			box_sack.texture = load("res://assets/BoxSack3.png")
			
	round = 0
	score = 0
	round_durations.clear()
	for i in range(rounds_total):
		round_durations.append(randf_range(3.0, 6.0))

	end_screen.visible = false
	pause_screen.visible = false
	continue_button.pressed.connect(_on_continue_pressed)
	_show_pause_screen()
	sack_stages = [
		load("res://assets/BoxSackBase.png"),  # normales Sprite
		load("res://assets/BXS1.png"),         # 50 Punkte
		load("res://assets/BXS2.png"),         # 100 Punkte
		load("res://assets/BXS3.png")          # optional weiteres Sprite
	]
	box_sack.texture = sack_stages[0]
	box_sack.texture = sack_stages[0]
	game_camera.make_current()
	load_highscores()
	_update_highscore_list()


func _input(event: InputEvent) -> void:
	if not game_active:
		return
	if not game_timer.is_stopped():
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			increase_score()
		elif event is InputEventScreenTouch and event.pressed:
			increase_score()
	# Sounds abspielen, abwechselnd
	

func _start_round() -> void:
	game_active = true
	pause_screen.visible = false
	timer_label.visible = true
#	score_label.visible = false # Score während der Runde ausblenden
	game_timer.wait_time = next_round_time
	game_timer.start()
	timer_label.text = "Time: %.1f" % game_timer.time_left

func update_box_sack() -> void:
	if score >= 150:
		# Boxsack zerstören
		if is_instance_valid(box_sack):
			box_sack.queue_free()
	elif score >= 100:
		box_sack.texture = sack_stages[2]  # 100 Punkte-Sprite
	elif score >= 50:
		box_sack.texture = sack_stages[1]  # 50 Punkte-Sprite
	else:
		box_sack.texture = sack_stages[0]  # Basis-Sprite

func _show_pause_screen() -> void:
	game_active = false
	pause_screen.visible = true
	timer_label.visible = false
	end_screen.visible = false

	pause_score_label.text = "Score: %d" % score
	if round < rounds_total:
		next_round_time = round_durations[round]
		next_round_time_label.text = "Nächste Runde: %.1f Sekunden" % next_round_time
		continue_button.disabled = false
		continue_button.visible = true
	else:
		pause_screen.visible = false
		_show_end_screen()

func _on_continue_pressed() -> void:
	continue_button.disabled = true
	round += 1
	if round <= rounds_total:
		_start_round()

func _process(_delta: float) -> void:
	if game_active and not game_timer.is_stopped():
		timer_label.text = "Time: %.1f" % game_timer.time_left

func _on_game_timer_timeout() -> void:
	if not game_active:
		return

	game_active = false
	round_count += 1

	if round_count < rounds_total:
		# Nächste Runde vorbereiten
		_show_pause_screen()
	else:
		# Finaler Endscreen nach letzter Runde
		end_screen.visible = true
		final_score_label.text = "Final Score: %d" % score
		timer_label.visible = false
		# Jetzt erst Highscore hinzufügen
		highscores.append(score)
		highscores.sort()
		highscores.reverse()
		_update_highscore_list()
		save_highscores()  

		# Anzeige (z. B. Top 5)
		var top_scores = highscores.slice(0, 5)
		var list_text := "Highscores:\n"
		for i in range(top_scores.size()):
			list_text += "%d. %d\n" % [i + 1, top_scores[i]]
		highscore_label.text = list_text
	if score > 150:
		# Effekt / Animation optional
		box_sack.queue_free()  # entfernt den Sack komplett
		box_sack.is_queued_for_deletion()



func increase_score() -> void:
	var points := 1
	if game_timer.time_left <= 2.0:
		points *= 2
	score += points
	#update_score_label()
	camera_shake()
	play_punch_sound()
	update_box_sack()   # <--- HIER wird nach Schwellen geprüft


func _show_end_screen() -> void:
	end_screen.visible = true
	final_score_label.text = "Final Score: %d" % score
	timer_label.visible = false
#	score_label.visible = false

func _update_highscore_list() -> void:
	var text = "Highscores:\n"
	for i in range(min(10, highscores.size())): # nur Top 10 anzeigen
		text += "%d. %d\n" % [i + 1, highscores[i]]
	highscore_label.text = text
	
const SAVE_FILE = "user://highscores.save"

func save_highscores() -> void:
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		file.store_var(highscores)

func load_highscores() -> void:
	if FileAccess.file_exists(SAVE_FILE):
		var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
		if file:
			highscores = file.get_var()

func camera_shake() -> void:
	for i in 3: # 3 schnelle Wackler
		var rand_x = randf_range(-10.0, 10.0)
		var rand_y = randf_range(-10.0, 10.0)
		game_camera.offset = Vector2(rand_x, rand_y)
		await get_tree().create_timer(0.4).timeout
	game_camera.offset = Vector2.ZERO
	
func play_punch_sound() -> void:
	if punch_sounds.is_empty():
		return
	var rand_index = randi_range(0, punch_sounds.size() - 1)
	punch_sounds[rand_index].play()


func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()
