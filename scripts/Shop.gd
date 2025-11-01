extends Node2D

@onready var coins_label: Label = $CoinsLabel
@onready var skins_list: VBoxContainer = $SkinList
@onready var back_button: Button = $Return

func _ready() -> void:
	# Lade globale Daten beim Öffnen des Shops
	Global.load_progress()
	update_ui()

	# Button-Event
	back_button.pressed.connect(_on_return_pressed)
# ----------------------------
# Skin kaufen
# ----------------------------
func _buy_skin(skin_name: String) -> void:
	var skin = Global.skins[skin_name]

	if not skin["owned"]:
		if Global.coins >= skin["cost"]:
			Global.coins -= skin["cost"]
			skin["owned"] = true
			Global.skins[skin_name] = skin
			Global.save_progress()
			update_ui()
			print("%s gekauft!" % skin_name)
		else:
			print("Nicht genug Münzen!")
func _ensure_skins_valid() -> void:
	if typeof(Global.skins) != TYPE_DICTIONARY:
		print("Global.skins ungültig, setze Default")
		Global.skins = {
			"default": {"cost": 0, "owned": true},
			"skin1": {"cost": 500, "owned": false}
		}
		Global.save_progress()
# ----------------------------
# UI aktualisieren
# ----------------------------
func update_ui() -> void:
	# Alle alten Einträge entfernen (verhindert Doppelung)
	for child in skins_list.get_children():
		child.queue_free()

	# Münzstand anzeigen
	coins_label.text = "Münzen: %d" % Global.coins

	# Für jeden Skin einen Eintrag mit Label + Button erzeugen
	for skin_name in Global.skins.keys():
		var skin_data = Global.skins[skin_name]
		var hbox = HBoxContainer.new()

		# Name + Kosten
		var label = Label.new()
		label.text = "%s (Kosten: %d)" % [skin_name, skin_data["cost"]]
		hbox.add_child(label)

		var button = Button.new()

		if skin_data["owned"]:
			# Skin gehört dem Spieler – Auswahl möglich
			if Global.current_skin == skin_name:
				button.text = "Ausgewählt"
				button.disabled = true
			else:
				button.text = "Auswählen"
				button.pressed.connect(func():
					_select_skin(skin_name)
				)
		else:
			# Skin ist noch nicht gekauft
			button.text = "Kaufen"
			button.pressed.connect(func():
				_buy_skin(skin_name)
			)

		hbox.add_child(button)
		skins_list.add_child(hbox)

# ----------------------------
# Skin auswählen
# ----------------------------
func _select_skin(skin_name: String) -> void:
	Global.current_skin = skin_name
	Global.save_progress()
	update_ui()
	print("%s wurde ausgewählt!" % skin_name)


# ----------------------------
# Zurück zum Endscreen
# ----------------------------
func _on_return_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Game.tscn")


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
