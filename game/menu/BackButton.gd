extends TextureButton

func _gui_input(event):
	if event.pressed:
		if event.is_action("ui_accept") or event.is_action("ui_cancel"):
			get_node("..").visible = false
			get_node("../../VBoxContainer/HowToButton").grab_focus()
