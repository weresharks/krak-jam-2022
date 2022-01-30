extends TextureButton

func _ready():
	grab_focus()

func _gui_input(event):
	if (event is InputEventKey or event is InputEventJoypadButton) and event.pressed:
		if event.is_action("ui_accept"):
			get_node("../SceneTransition").transition()
			get_node("../MusicTransition").transition()
