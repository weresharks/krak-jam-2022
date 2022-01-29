extends AudioStreamPlayer

func play_sound(sound: AudioStream):
	$AudioPlayer.stream = sound
	$AudioPlayer.play()
