extends ParallaxLayer

var forward = true
var limit = 3

func _process(delta):
	if forward:
		$Sprite.position.x += delta
		if $Sprite.position.x >= limit:
			forward = false
	else:
		$Sprite.position.x -= delta
		if $Sprite.position.x <= -limit:
			forward = true
