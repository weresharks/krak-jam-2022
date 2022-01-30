extends TextureButton
class_name DifficultyLevelButton

export var difficulty_level: int
export var is_selected: bool

func _gui_input(event):
	if event.pressed:
		if event.is_action("ui_accept"):
			Global.difficulty_level = difficulty_level
			get_node("../..").grab_focus()
		elif event.is_action("ui_cancel"):
			get_node("../..").grab_focus()
