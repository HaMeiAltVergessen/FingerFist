extends Node2D

# --- Nodes (prüfe Pfade) ---
@onready var end_screen: CanvasLayer = $EndScreen
@onready var pause_screen: CanvasLayer = $PauseScreen
@onready var sprite = $Background/BoxFingerSprite  # falls dein Player ein Sprite2D-Node hat

@onready var coin_layer: CanvasLayer = $CoinLayer

@onready var continue_button: Button = $PauseScreen/ContinueButton
@onready var retry_button: Button = $EndScreen/RetryButton
@onready var shop_button: Button = $EndScreen/ShopButton

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

# --- Spielvariablen ---
var score: int = 0
var round: int = 0
var rounds_total: int = 3
var round_durations: Array = []
var next_round_time: int = 0
var game_active: bool = false
var sack_stages: Array[Texture2D] = []  # Texturen für Schaden
var round_count: int = 0
# Hinweis: Highscores / total_score liegen jetzt in Global.*
var coin_scene = preload("res://scenes/Coins.tscn")
# Coin-Spawn-Kontrolle
var coin_timer: float = 0.0
var coin_spawn_interval := 1.5 # Sekunden zwischen Spawns
var can_spawn_coins: bool = false

# -----------------------
# READY
# -----------------------
func _ready() -> void:
	randomize()
	can_spawn_coins = false   # WICHTIG: am Scene-Start niemals spawnen
	Global.load_progress()
	_apply_progression()
	round = 0
	score = 0
	round_durations.clear()
	for i in range(rounds_total):
		round_durations.append(randf_range(3.0, 6.0))
	end_screen.visible = false
	pause_screen.visible = false
	sprite.texture = Global.get_current_skin_texture()
	# Sack-Stages laden
	sack_stages = [
		load("res://assets/BoxSackBase.png"),
		load("res://assets/BXS1.png"),
		load("res://assets/BXS2.png"),
		load("res://assets/BXS3.png")
	]
	if box_sack:
		box_sack.texture = sack_stages[0]
	game_camera.make_current()
	_update_highscore_list()
	_show_pause_screen()

# -----------------------
# INPUT & SCORE
# -----------------------
func _input(event: InputEvent) -> void:
	if not game_active:
		return
	if not game_timer.is_stopped():
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_on_valid_input()
		elif event is InputEventScreenTouch and event.pressed:
			_on_valid_input()

func _on_valid_input() -> void:
	var points := 1
	if game_timer.time_left <= 2.0:
		points = 2
	score += points

	# Effekte
	camera_shake()
	play_punch_sound()

	# Boxsack nur verändern, wenn Schwellen erreicht sind
	update_box_sack()

# -----------------------
# Runden / Timer
# -----------------------
func _start_round() -> void:
	game_active = true
	pause_screen.visible = false
	timer_label.visible = true
	game_timer.wait_time = next_round_time
	game_timer.start()
	timer_label.text = "Time: %.1f" % game_timer.time_left


func _process(_delta: float) -> void:
	if not game_active:
		return
	if get_tree().paused:
		return
	if game_timer.is_stopped():
		return

	# Timer-Update / Label
	timer_label.text = "Time: %.1f" % game_timer.time_left

	# coin spawn nur wenn freigegeben
	if can_spawn_coins:
		coin_timer += _delta
		if coin_timer >= coin_spawn_interval:
			coin_timer = 0.0
			coin_spawn_interval = randf_range(1.0, 2.5)
			spawn_coin()
func _on_game_timer_timeout() -> void:
	if not game_active:
		return
	game_active = false
	can_spawn_coins = false
	round_count += 1

	# Falls noch Runden übrig -> Pause
	if round_count < rounds_total:
		_show_pause_screen()

	else:
		# Runde komplettiert -> Endscreen
		end_screen.visible = true
		final_score_label.text = "Final Score: %d" % score
		timer_label.visible = false
		


		# === WICHTIG: global speichern (einmal) ===
		Global.add_score(score)            # aktualisiert Global.total_score & Global.highscores & speichert
		_apply_progression()               # falls neue Level unlocked wurden, aktualisieren
		_update_highscore_list()           # UI aus Global.highscores füllen

		# falls Sack zerstört werden soll (Score-basiert)
		if score >= 150 and is_instance_valid(box_sack):
			_play_sack_destroy_effect()
			await get_tree().create_timer(0.35).timeout
			if is_instance_valid(box_sack):
				box_sack.queue_free()

# -----------------------
# Boxsack / Schwellen
# -----------------------
func update_box_sack() -> void:
	if not is_instance_valid(box_sack):
		return
	if score >= 150:
		# Zerstört -> Optional visual
		box_sack.texture = sack_stages[3]
	elif score >= 100:
		box_sack.texture = sack_stages[2]
	elif score >= 50:
		box_sack.texture = sack_stages[1]
	else:
		box_sack.texture = sack_stages[0]

func _play_sack_destroy_effect() -> void:
	# kleines Fade-out Tween als Effekt
	if not box_sack:
		return
	var tw = create_tween()
	tw.tween_property(box_sack, "modulate:a", 0.0, 0.35)

# -----------------------
# Progression / UI
# -----------------------
func _apply_progression() -> void:
	match Global.unlocked_levels:
		1:
			$Background/BackgroundSprite.texture = load("res://assets/Free Pixel Art Forest/PNG/Background layers/Layer_0002_7.png")
			if box_sack:
				box_sack.texture = load("res://assets/BoxSackBase.png")
		2:
			$Background/BackgroundSprite.texture = load("res://assets/Free Pixel Art Forest/PNG/Background layers/Layer_0003_6.png")
			if box_sack:
				box_sack.texture = load("res://assets/BXS2.png")
		3:
			$Background/BackgroundSprite.texture = load("res://assets/Free Pixel Art Forest/PNG/Background layers/Layer_0009_2.png")
			if box_sack:
				box_sack.texture = load("res://assets/Free Pixel Art Forest/PNG/Background layers/Layer_0009_2.png")

func _show_pause_screen() -> void:
	game_active = false
	can_spawn_coins = false     # kein Spawning während Pause
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


func _show_end_screen() -> void:
	Global.add_score(score)
	if Global.rounds_played >= 3:
		Global.rounds_played = 0 # nach Anzeige wieder zurücksetzen
		get_tree().change_scene_to_file("res://scenes/Shop.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/EndScreen.tscn")
	end_screen.visible = true
	final_score_label.text = "Final Score: %d" % score
	timer_label.visible = false
	

# -----------------------
# Highscore UI (liest aus Global.highscores)
# -----------------------
func _update_highscore_list() -> void:
	var text := "Highscores:\n"
	for i in range(min(10, Global.highscores.size())):
		text += "%d. %d\n" % [i + 1, Global.highscores[i]]
	highscore_label.text = text

# -----------------------
# Sounds / Camera
# -----------------------
func play_punch_sound() -> void:
	if punch_sounds.is_empty():
		return
	var rand_index := randi() % punch_sounds.size()
	punch_sounds[rand_index].play()

func camera_shake() -> void:
	if not game_camera:
		return
	for i in range(3):
		var rx := randf_range(-12.0, 12.0)
		var ry := randf_range(-12.0, 12.0)
		game_camera.offset = Vector2(rx, ry)
		await get_tree().create_timer(0.04).timeout
	game_camera.offset = Vector2.ZERO
	
# -----------------------
# Coin
# -----------------------
func spawn_coin() -> void:
	if not game_active or not can_spawn_coins:
		return

	# instantiate
	var coin = coin_scene.instantiate()

	# position über Spielbereich
	coin.position = Vector2(randf_range(100, 700), -20)

	# Füge IMMER in coin_layer ein — kein fallback add_child
	if coin_layer == null:
		push_error("CoinLayer nicht gefunden! Pfad prüfen.")
		return

	coin_layer.add_child(coin)

	# sicherstellen, dass coin pausiert, wenn Spiel pausiert
	coin.process_mode = Node.PROCESS_MODE_PAUSABLE

	# Wenn CoinLayer kein CanvasLayer ist, setze z_index, ansonsten setze layer
	if coin_layer is CanvasLayer:
		# CanvasLayer wird oben aufgerendert; du kannst layer höher setzen, falls nötig
		coin_layer.layer = 1
	else:
		# Node2D -> z_index am Coin
		if coin is CanvasItem:
			coin.z_index = 100
# -----------------------
# Retry
# -----------------------
func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()

func _on_shop_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Shop.tscn")

func _on_continue_button_pressed() -> void:
	continue_button.disabled = true
	round += 1
	coin_timer = 0.0
	if round <= rounds_total:
		can_spawn_coins = true     # Coins dürfen wieder spawnen
		_start_round()
