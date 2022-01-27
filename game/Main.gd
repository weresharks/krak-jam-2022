extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	$Tank.start(Vector2(3000, 800))


func _process(delta):
	$Debug/pos_x.text = str(int($Tank.position.x))
	$Debug/pos_y.text = str(int($Tank.position.y))
	
