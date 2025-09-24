extends Node2D

@onready var pause_screen: CanvasLayer = $PauseScreen
@onready var continue_button: Button = $PauseScreen/ContinueButton
@onready var pause_score_label: Label = $PauseScreen/PauseScoreLabel
@onready var next_round_time_label: Label = $PauseScreen/NextRoundTimeLabel
@onready var retry_button: Button = $EndScreen/RetryButton
@onready var timer_label: Label = $GameScreen/TimerLabel
#@onready var score_label: Label = $ScoreLabel
@onready var final_score_label: Label = $EndScreen/FinalScore
@onready var end_screen: CanvasLayer = $EndScreen
@onready var game_timer: Timer = $GameTimer
@onready var box_sack: Sprite2D = $GameScreen/BoxSack
@onready var game_camera: Camera2D = $GameCamera

var score: int = 0
var round: int = 0
var rounds_total: int = 3
var round_durations: Array = []
var next_round_time: int = 0
var game_active: bool = false
var sack_stages: Array[Texture2D] = []  # Texturen für Schaden
var highscore: int = 0

func _ready() -> void:
	randomize()
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
	load("res://assets/BXS1.png"),
	load("res://assets/BXS2.png"),
	load("res://assets/BXS3.png"),
	load("res://assets/BoxSackBase.png")
]
#box_sack.texture = sack_stages[0]

func _show_pause_screen() -> void:
	game_active = false
	pause_screen.visible = true
	timer_label.visible = false
#	score_label.visible = false
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

func _start_round() -> void:
	game_active = true
	pause_screen.visible = false
	timer_label.visible = true
#	score_label.visible = false # Score während der Runde ausblenden
	game_timer.wait_time = next_round_time
	game_timer.start()
	timer_label.text = "Time: %.1f" % game_timer.time_left

func _on_continue_pressed() -> void:
	continue_button.disabled = true
	round += 1
	if round <= rounds_total:
		_start_round()

func _process(_delta: float) -> void:
	if game_active and not game_timer.is_stopped():
		timer_label.text = "Time: %.1f" % game_timer.time_left

func _on_game_timer_timeout() -> void:
	if game_active:
		game_active = false
		_show_pause_screen()

func _input(event: InputEvent) -> void:
	if not game_active:
		return
	if not game_timer.is_stopped():
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			increase_score()
		elif event is InputEventScreenTouch and event.pressed:
			increase_score()

func increase_score() -> void:
	var points := 1
	if game_timer.time_left <= 2.0:
		points *= 2
	score += points
	#update_score_label()
	camera_shake()

func _show_end_screen() -> void:
	end_screen.visible = true
	final_score_label.text = "Final Score: %d" % score
	timer_label.visible = false
#	score_label.visible = false

func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()	
	
func camera_shake() -> void:
	var rand_x = randf_range(-5.0, 5.0)
	var rand_y = randf_range(-5.0, 5.0)
	game_camera.offset = Vector2(rand_x, rand_y)
	# Nach sehr kurzer Zeit zurücksetzen
	await get_tree().create_timer(0.05).timeout
	game_camera.offset = Vector2.ZERO
