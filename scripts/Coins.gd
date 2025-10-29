extends Area2D

@onready var sprite: Sprite2D = $Sprite2D

# Physikparameter
var gravity_force: float = 900.0
var vel_y: float = 0.0
var bounce_damping: float = 0.5  # Wie stark der Bounce abnimmt
var min_bounce_speed: float = 50.0  # Ab dieser Geschwindigkeit kein Bounce mehr

func _ready() -> void:
	connect("input_event", Callable(self, "_on_input_event"))
	connect("area_entered", Callable(self, "_on_area_entered"))
	process_mode = Node.PROCESS_MODE_PAUSABLE

func _process(delta: float) -> void:
	if get_tree().paused:
		return

	# Schwerkraft
	vel_y += gravity_force * delta
	position.y += vel_y * delta

func _on_area_entered(area: Area2D) -> void:
	if area.name == "GroundBounce":
				# Falls es noch einen richtigen Boden gibt
		queue_free()
		# Münze berührt Boden → Bouncen
	elif area.name == "Ground":
		if abs(vel_y) > min_bounce_speed:
			vel_y = -vel_y * bounce_damping  # umkehren und dämpfen
			position.y -= 4  # leicht anheben, um „Steckenbleiben“ zu verhindern

func _on_input_event(viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed:
		var gained := randi_range(10, 50)
		Global.coins += gained
		Global.save_progress()

		var tw := create_tween()
		tw.tween_property(self, "scale", scale * 1.3, 0.1)
		tw.tween_property(self, "scale", Vector2.ZERO, 0.2)
		await tw.finished
		queue_free()
