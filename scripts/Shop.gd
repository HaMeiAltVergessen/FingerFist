extends Node2D    # <- wichtig: für UI-Control-Layout (besser als Node2D)

@onready var coins_label: Label = $CoinsLabel
@onready var skins_list: VBoxContainer = $SkinList
@onready var back_button: Button = $Return

func _ready() -> void:
	# Button-Verbindung
	if not back_button.pressed.is_connected(_on_return_pressed):
		back_button.pressed.connect(_on_return_pressed)
	# Erstes UI aufbauen
	_build_shop_ui()

# baut die gesamte Liste neu auf (löscht vorher alte Einträge)
func _build_shop_ui() -> void:
	# coins anzeigen
	_update_coins_label()

	# Alte Einträge löschen (vermeidet Duplikate)
	for child in skins_list.get_children():
		child.queue_free()

	# Neue Einträge hinzufügen
	for skin_name in Global.skins.keys():
		var data = Global.skins[skin_name]
		var hbox = HBoxContainer.new()
		hbox.custom_minimum_size = Vector2(0, 36) # optional für Zeilenhöhe

		var label = Label.new()
		label.text = "%s (Kosten: %d)" % [skin_name, data["cost"]]
		hbox.add_child(label)

		var button = Button.new()
		# sichere Verbindung mit gebundener Variable
		if data["owned"]:
			if Global.current_skin == "res://assets/Finger 01.png":
				button.text = "Ausgewählt"
				button.disabled = true
			else:
				button.text = "Auswählen"
				var c = Callable(self, "_select_skin").bind(skin_name)
				button.pressed.connect(c)
		else:
			button.text = "Kaufen"
			var cbuy = Callable(self, "_buy_skin").bind("res://assets/Finger 02.png")
			button.pressed.connect(cbuy)

		hbox.add_child(button)
		skins_list.add_child(hbox)

func _update_coins_label() -> void:
	coins_label.text = "Münzen: %d" % Global.coins

# -------------------
# Aktionen
# -------------------
func _select_skin(skin_name: String) -> void:
	Global.current_skin = skin_name
	Global.save_progress()
	_build_shop_ui()        # UI aktualisieren (Buttons / Ausgewählt-Status)
	_update_coins_label()

func _buy_skin(skin_name: String) -> void:
	var skin = Global.skins.get(skin_name)
	if skin == null:
		return
	if skin["owned"]:
		return
	if Global.coins >= skin["cost"]:
		Global.coins -= skin["cost"]
		skin["owned"] = true
		Global.skins[skin_name] = skin
		Global.save_progress()
		_build_shop_ui()
		_update_coins_label()
	else:
		# Optional: zeige ein Popup oder Sound
		print("Nicht genug Münzen!")

func _on_return_pressed() -> void:
	# Zurück zur EndScreen (oder zu Game/Highscore je nach Flow)
	get_tree().change_scene_to_file("res://scenes/Game.tscn")
