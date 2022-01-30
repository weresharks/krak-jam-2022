extends TextureButton

func _gui_input(event):
	if (event is InputEventKey or event is InputEventJoypadButton) and event.pressed:
		if event.is_action("ui_accept"):
			get_selected().grab_focus()

func get_selected():
	var level_buttons = []
	for child in $HBoxContainer.get_children():
		if child is DifficultyLevelButton:
			level_buttons.append(child)
			
	for button in level_buttons:
		if button.is_selected:
			return button
