extends Area2D

var is_mob = true

export var tank_detection_range: float = 300
export var nimble_range: float = 100

export var base_speed: float = 50
export var speed_variation: float = 10

export var hunting_impulse: float = 0.24

export var slowdown_impulse: float = 0.3
export var slowdown_cutoff_speed: float = 5

export var max_spontaneous_speed: float = 10
export var spontaneous_impulse = 2


var tank_detection_range_squared: float
var tank

var nimble_range_squared: float
var nimble

var speed: float
var velocity: Vector2 = Vector2.ZERO
var rotation_speed = 0.1 * PI

var collided: bool = false


func start(pos: Vector2):
	position = pos
	speed = base_speed + rand_range(-speed_variation, speed_variation)


# Called when the node enters the scene tree for the first time.
func _ready():
	tank_detection_range_squared = tank_detection_range * tank_detection_range
	nimble_range_squared = nimble_range * nimble_range

func set_tank(_tank):
	tank = _tank

func set_nimble(_nimble):
	nimble = _nimble


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var hunting: Vector2 = Vector2.ZERO
	var slowdown: Vector2 = Vector2.ZERO
	var spontaneous: Vector2 = Vector2.ZERO

	var tank_dist_2 = position.distance_squared_to(tank.position)
	if tank_dist_2 < tank_detection_range_squared:
		var tank_dir = position.direction_to(tank.position)
		hunting = tank_dir * hunting_impulse
	else:
		spontaneous = Vector2.UP.rotated(rand_range(0, 2 * PI)) * spontaneous_impulse
		
		if velocity.length() >= slowdown_cutoff_speed:
			slowdown = - velocity.normalized() * slowdown_impulse
	
	velocity = velocity + hunting + slowdown + spontaneous
	
	position += velocity * delta
	rotation += rotation_speed * delta
