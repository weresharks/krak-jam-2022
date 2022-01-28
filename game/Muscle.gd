extends ParallaxLayer

var forward = true
var limit = 4

func _process(delta):
	if forward:
		$Sprite.position.x += delta
		$Sprite.position.y += delta
		if $Sprite.position.x >= limit:
			forward = false
	else:
		$Sprite.position.x -= delta
		$Sprite.position.y -= delta
		if $Sprite.position.x <= -limit:
			forward = true
