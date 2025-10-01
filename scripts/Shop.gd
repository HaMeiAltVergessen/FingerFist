extends Node2D

@onready var coins_label: Label = $CoinsLabel
@onready var skins_list: VBoxContainer = $SkinList
@onready var back_button: Button = $Return

func _ready() -> void:
	update_ui()
	back_button.pressed.connect(_on_return_pressed)

func update_ui() -> void:
	coins_label.text = "Münzen: %d" % Global.coins
	#skins_list.clear()
	for skin_name in Global.skins.keys():
		var data = Global.skins[skin_name]
		var hbox = HBoxContainer.new()
		
		var label = Label.new()
		label.text = "%s (Kosten: %d)" % [skin_name, data["cost"]]
		hbox.add_child(label)

		var button = Button.new()
		if data["owned"]:
			if Global.current_skin == skin_name:
				button.text = "Ausgewählt"
				button.disabled = true
			else:
				button.text = "Auswählen"
				button.pressed.connect(func():
					Global.current_skin = skin_name
					Global.save_game()
					update_ui()
				)
		else:
			button.text = "Kaufen"
			button.pressed.connect(func():
				if Global.coins >= data["cost"]:
					Global.coins -= data["cost"]
					data["owned"] = true
					Global.skins[skin_name] = data
					Global.save_game()
					update_ui()
				else:
					print("Nicht genug Münzen!")
			)
		hbox.add_child(button)
		skins_list.add_child(hbox)

func _on_return_pressed() -> void:
	get_tree().change_scene_to_file("res://EndScreen.tscn")
