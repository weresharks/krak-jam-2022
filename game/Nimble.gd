extends Node2D


var tank_pos: Vector2
export var max_speed: float = 200
export var min_speed: float = 5
export var start_speed: float = 30
export var gravity_base: float = 1000
export var min_gravity_distance_2: float = 20*20
export var longing_base: float = 0.1
export var longing_distance: float = 100
export var acceleration_impulse: float = 10
export var turning_impulse: float = 1

var velocity: Vector2

var longing: Vector2

var acceleration_map: Dictionary

func get_acceleration_map() -> Dictionary:
	return {
		"nimble_left": Vector2(-acceleration_impulse, 0),
		"nimble_right": Vector2(acceleration_impulse, 0),
		"nimble_up": Vector2(0, -acceleration_impulse),
		"nimble_down": Vector2(0, acceleration_impulse),
	}

# Called when the node enters the scene tree for the first time.
func _ready():
	acceleration_map = get_acceleration_map()

func start(start_pos: Vector2):
	position = start_pos
	velocity = Vector2(0, start_speed).rotated(rand_range(0, 2 * PI))

func update_tank_pos(_tank_pos: Vector2):
	tank_pos = _tank_pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var tank_dist = position.distance_to(tank_pos)
	var tank_dist_2 = tank_dist * tank_dist
	var gravity_impulse: float = 0
	if tank_dist_2 > min_gravity_distance_2:
		gravity_impulse = gravity_base / tank_dist_2
	var gravity = position.direction_to(tank_pos) * gravity_impulse
	
	var longing_impulse: float = 0
	if tank_dist > longing_distance:
		longing_impulse = longing_base * (tank_dist - longing_distance)
	
	longing = position.direction_to(tank_pos) * longing_impulse
	
	var acceleration = Vector2.ZERO
	
	# needed for turning/longitudal aka tank aka driving acceleration controls
#	var acceleration_map: Dictionary = calc_driving_controls_map(velocity)
	
	for key in acceleration_map.keys():
		if Input.is_action_pressed(key):
			acceleration += acceleration_map[key]

	velocity += gravity + longing + acceleration
	
	var vlen: float = velocity.length()
	
	if vlen > max_speed:
		velocity = velocity.normalized() * max_speed
	elif vlen < min_speed:
		velocity = Vector2(0, -1).rotated(rotation) * min_speed

	position += velocity * delta
	rotation = Vector2(0, -1).angle_to(velocity)


func calc_driving_controls_map(v: Vector2) -> Dictionary:
	var half_pi: float = PI / 2
	v = v.normalized()	
	return {
		"nimble_left": v.rotated(- half_pi) * turning_impulse,
		"nimble_right": v.rotated(+ half_pi) * turning_impulse,
		"nimble_forward": v * acceleration_impulse,
		"nimble_back": v * (- acceleration_impulse / 2),
	}
