extends Node2D


export var max_velocity = 100

var velocity = Vector2.ZERO
export var acceleration_impulse: float = 5

var acceleration_map: Dictionary

func init_acceleration_map():	
	acceleration_map = {
		"tank_left": Vector2(-acceleration_impulse, 0),
		"tank_right": Vector2(acceleration_impulse, 0),
		"tank_up": Vector2(0, -acceleration_impulse),
		"tank_down": Vector2(0, acceleration_impulse),
	}

# Called when the node enters the scene tree for the first time.
func _ready():
	init_acceleration_map()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var acceleration = Vector2.ZERO
	
	for key in acceleration_map.keys():
		if Input.is_action_pressed(key):
			acceleration += acceleration_map[key]
	
	velocity += acceleration
	
	position += velocity * delta

