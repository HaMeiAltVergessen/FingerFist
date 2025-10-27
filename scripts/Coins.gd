extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var acceleration: float = 600.0
var velocity: float = 0.0
var bounce_damping: float = 0.6         # wie stark der Bounce abgeschwächt wird (0.6 = verliert 40% Energie)
var min_bounce_velocity: float = 30.0   # unterhalb dieser Geschwindigkeit stoppt der Bounce
var ground_y: float = 0.0               # wird beim ersten Kontakt mit Boden gesetzt
var on_ground: bool = false

func _ready() -> void:
	connect("input_event", Callable(self, "_on_input_event"))
	connect("area_entered", Callable(self, "_on_area_entered"))

func _process(delta: float) -> void:
	if on_ground:
		return

	# Gravitation
	velocity += acceleration * delta
	position.y += velocity * delta

	# Falls Münze unter Boden liegt, korrigiere und bounce
	if ground_y != 0.0 and position.y > ground_y:
		position.y = ground_y
		velocity = -velocity * bounce_damping

		# Wenn Bounce zu schwach, Münze "liegt" still
		if abs(velocity) < min_bounce_velocity:
			velocity = 0
			on_ground = true

func _on_input_event(viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed:
		var gained = randi_range(10, 50)
		Global.coins += gained
		Global.save_progress()
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.name == "Ground":
		# Bodenposition merken
		ground_y = area.global_position.y - 8  # ggf. Offset anpassen (abhängig von deiner Spritehöhe)
