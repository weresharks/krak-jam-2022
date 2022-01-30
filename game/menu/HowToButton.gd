extends TextureButton

func _gui_input(event):
	if (event is InputEventKey or event is InputEventJoypadButton) and event.pressed:
		if event.is_action("ui_accept"):
			var tutorial_root = get_node("../../TutorialScreen")
			tutorial_root.visible = true
			tutorial_root.get_node("BackButton").grab_focus()
