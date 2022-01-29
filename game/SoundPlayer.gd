extends AudioStreamPlayer

func play_sound(sound: AudioStream):
	pitch_scale = 1
	stream = sound
	play()

func play_random_sound(sounds: Array, randomize_pitch: bool = false):
	if randomize_pitch:
		pitch_scale += rand_range(-0.2, 0.2)
	else:
		pitch_scale = 1
	stream = sounds[randi() % sounds.size()]
	play()
