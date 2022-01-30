extends Node

export(float) var volume_db = 0 setget set_volume

func _ready():
	$AnimationPlayer.play_backwards("FadeMusic")

func transition():
	$AnimationPlayer.play("FadeMusic")
	yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play_backwards("FadeMusic")

func set_volume(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), -value)
