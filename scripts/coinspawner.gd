extends Node2D

@export var coin_scene: PackedScene
@export var coins_to_spawn: int = 10
@export var min_acceleration: float = 400.0
@export var max_acceleration: float = 900.0
@export var min_delay: float = 0.2
@export var max_delay: float = 1.2

var coins_spawned: int = 0

func _ready():
	spawn_next_coin()

func spawn_next_coin():
	if coins_spawned >= coins_to_spawn:
		return

	var coin = coin_scene.instantiate()

	# Zufällige X-Position am oberen Rand
	var viewport_width = get_viewport().size.x
	coin.global_position.x = randi_range(16, viewport_width - 16)
	coin.global_position.y = 0

	# Zufällige Anfangs-Geschwindigkeit oder Gravitation
	# Variante A (Startgeschwindigkeit):
	coin.vel_y = randf_range(min_acceleration, max_acceleration)
	# Variante B (Schwerkraft):
	# coin.gravity_force = randf_range(min_acceleration, max_acceleration)

	add_child(coin)

	coins_spawned += 1

	# Timer für verzögertes nächstes Spawnen
	var delay = randf_range(min_delay, max_delay)
	await get_tree().create_timer(delay).timeout
	spawn_next_coin()
