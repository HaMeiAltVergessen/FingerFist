extends Area2D
## Features:
# Muss noch länger laufen, mehr Coins, nur wenn Game auch aktiv ist, Sounds wenn angeklickt, Counter für Münzen
@onready var sprite: Sprite2D = $Sprite2D
var acceleration: float = 600.0 # Standardwert, wird vom Spawner gesetzt!
var velocity: float = 0.0

func _ready() -> void:
	connect("input_event", Callable(self, "_on_input_event"))
	connect("area_entered", Callable(self, "_on_area_entered"))

func _process(delta: float) -> void:
	velocity += acceleration * delta
	position.y += velocity * delta

func _on_input_event(viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed:
		var gained = randi_range(10, 50)
		Global.coins += gained
		Global.save_progress()
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.name == "Ground":
		queue_free()
