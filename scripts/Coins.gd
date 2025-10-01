extends Area2D

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	connect("input_event", Callable(self, "_on_input_event"))

func _on_input_event(viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed:
		var gained = randi_range(10, 50)
		Global.coins += gained
		Global.save_progress()
		queue_free()


func _on_shop_button_pressed() -> void:
	pass # Replace with function body.
