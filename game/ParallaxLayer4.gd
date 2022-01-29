extends ParallaxLayer

export var wobble_magnitude: float = 6
export var wobble_speed: float = PI / 2
var wobble_phase: float = 0

var pos: Vector2

func _ready():
	pos = $Sprite.position

func _process(delta):
	wobble_phase += delta * wobble_speed
	var wobble_translation: Vector2 = Vector2.UP.rotated(wobble_phase) * wobble_magnitude
	$Sprite.position = pos + wobble_translation
