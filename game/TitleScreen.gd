extends Control

export (Array, Texture) var monsters

func _ready():
	if Global.high_score > 0:
		$HighScore/high_score.text = str(Global.high_score)
		$HighScore/label_high_score.show()
		$HighScore/high_score.show()
	if Global.last_game_score > 0:
		$HighScore/score.text = str(Global.last_game_score)
		$HighScore/label_score.show()
		$HighScore/score.show()
		
		randomize()
		var monster = monsters[randi() % monsters.size()]
		$Monster.texture = monster
