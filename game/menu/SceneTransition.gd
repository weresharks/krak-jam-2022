extends ColorRect

export(String, FILE, "*.tscn") var next_scene_path

func _ready():
	$AnimationPlayer.play_backwards("Fade")

func transition():
	$AnimationPlayer.play("Fade")
	yield($AnimationPlayer, "animation_finished")
	get_tree().change_scene(next_scene_path)
