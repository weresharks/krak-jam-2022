extends Node2D


var tank_pos: Vector2
export var max_speed: float = 100
export var min_speed: float = 5
export var start_speed: float = 30
export var gravity_base: float = 500
export var min_gravity_distance: float = 20*20

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
	position += velocity * delta
	var tank_dist2 = position.distance_squared_to(tank_pos)
	var gravity_impulse: float = 0
	if tank_dist2 > min_gravity_distance:
		gravity_impulse = gravity_base / tank_dist2
	var gravity = position.direction_to(tank_pos) * gravity_impulse
	
	velocity += gravity
	
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

	rotation = Vector2(0, -1).angle_to(velocity)
