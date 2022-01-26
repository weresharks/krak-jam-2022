extends Node2D


export var max_velocity: float = 100
export var acceleration_impulse: float = 5
export var deceleration_impulse: float = 1
export var margin_deceleration_impulse: float = 10
export var max_acceleration: float = 5
export var rotation_speed = 3

var velocity = Vector2.ZERO
var margin = 20
var max_position: Vector2

var acceleration_map: Dictionary

func init_acceleration_map():	
	acceleration_map = {
		"tank_left": Vector2(-acceleration_impulse, 0),
		"tank_right": Vector2(acceleration_impulse, 0),
		"tank_up": Vector2(0, -acceleration_impulse),
		"tank_down": Vector2(0, acceleration_impulse),
	}

func start(screen_size):
	position = screen_size / 2
	max_position = screen_size

# Called when the node enters the scene tree for the first time.
func _ready():
	init_acceleration_map()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var acceleration = Vector2.ZERO
	
	for key in acceleration_map.keys():
		if Input.is_action_pressed(key):
			acceleration += acceleration_map[key]
	
	if position.x < margin and velocity.x < 0:
		acceleration.x = margin_deceleration_impulse
	if position.x > max_position.x - margin and velocity.x > 0:
		acceleration.x = - margin_deceleration_impulse
	
	if position.y < margin and velocity.y < 0:
		acceleration.y = margin_deceleration_impulse
	if position.y > max_position.y - margin and velocity.y > 0:
		acceleration.y = - margin_deceleration_impulse
	
	if acceleration.length() > max_acceleration:
		acceleration = acceleration.normalized() * max_acceleration
	
	velocity += acceleration
	
	if velocity.length() > max_velocity:
		velocity = velocity.normalized() * max_velocity
	
	position += velocity * delta
	rotation_degrees += rotation_speed * delta
