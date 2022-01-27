extends Node2D


var tank_pos: Vector2
export var max_speed: float = 70
export var min_speed: float = 5
export var start_speed: float = 30
export var gravity_base: float = 1000
export var min_gravity_distance: float = 20*20
export var acceleration_impulse: float = 10
export var turning_impulse: float = 1

var velocity: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func start(start_pos: Vector2):
	position = start_pos
	velocity = Vector2(0, start_speed).rotated(rand_range(0, 2 * PI))
	#velocity = Vector2(0, 0)

func update_tank_pos(_tank_pos: Vector2):
	tank_pos = _tank_pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var tank_dist2 = position.distance_squared_to(tank_pos)
	var gravity_impulse: float = 0
	if tank_dist2 > min_gravity_distance:
		gravity_impulse = gravity_base / tank_dist2
	var gravity = position.direction_to(tank_pos) * gravity_impulse
	
	var acceleration = Vector2.ZERO
	
	
	var accelleration_map: Dictionary = calc_acceleration_map(velocity)
	
	for key in accelleration_map.keys():
		if Input.is_action_pressed(key):
			acceleration += accelleration_map[key]

	velocity += gravity + acceleration
	
	var vlen: float = velocity.length()
	
	if vlen > max_speed:
		velocity = velocity.normalized() * max_speed
	elif vlen < min_speed:
		velocity = Vector2(0, -1).rotated(rotation) * min_speed

	position += velocity * delta
	rotation = Vector2(0, -1).angle_to(velocity)

func calc_acceleration_map(v: Vector2) -> Dictionary:
	var half_pi: float = PI / 2
	v = v.normalized()	
	return {
		"nimble_left": v.rotated(- half_pi) * turning_impulse,
		"nimble_right": v.rotated(+ half_pi) * turning_impulse,
		"nimble_forward": v * acceleration_impulse,
		"nimble_back": v * (- acceleration_impulse / 2),
	}
