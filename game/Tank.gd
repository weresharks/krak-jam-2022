extends Area2D

export var max_speed: float = 100
export var min_speed: float = 10
export var max_speed_spontaneous: float = 20
export var spontaneous_acceleration_impulse: float = 0.2
export var acceleration_impulse: float = 3
export var deceleration_impulse: float = 0.3
export var margin_deceleration_impulse: float = 10
export var max_acceleration: float = 5
export var rotation_speed: float = 3
export var scale_speed: float = 0 # PI / 10 # 0 -> disable scaling
export var scale_magnitude: float = 0.3

var velocity = Vector2.ZERO
var margin = 20
var max_position: Vector2
var base_scale: Vector2
var scale_phase: float = 0

export var start_energy: float = 100
var energy: float
var max_energy: float = 1000
var energy_nominal: float = 100
var energy_usage: float = 0.5
var energy_damage: float = 20
var energy_gain: float = 20

var acceleration_map: Dictionary

var dead: bool
var goal_reached: bool


func get_acceleration_map() -> Dictionary:
	return {
		"tank_left": Vector2(-acceleration_impulse, 0),
		"tank_right": Vector2(acceleration_impulse, 0),
		"tank_up": Vector2(0, -acceleration_impulse),
		"tank_down": Vector2(0, acceleration_impulse),
	}

func start(screen_size):
	position = screen_size / 2
	max_position = screen_size
	
	energy = start_energy
	velocity = Vector2.ZERO
	dead = false
	goal_reached = false


# Called when the node enters the scene tree for the first time.
func _ready():
	acceleration_map = get_acceleration_map()
	base_scale = scale

func update_energy(energy_delta):
	energy += energy_delta
	energy = clamp(energy, 0, max_energy)
	if energy <= 0:
		dead = true

func energy_adjustment():
	var adj = energy / energy_nominal
	return adj

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	var acceleration = Vector2.ZERO
	
	for key in acceleration_map.keys():
		if Input.is_action_pressed(key):
			acceleration += acceleration_map[key]

	var vel_len: float = velocity.length()

	if acceleration.length_squared() == 0 and vel_len < max_speed_spontaneous:
		acceleration = Vector2(
			rand_range(0, spontaneous_acceleration_impulse) - spontaneous_acceleration_impulse / 2, 
			rand_range(0, spontaneous_acceleration_impulse) - spontaneous_acceleration_impulse / 2
		)
	
	# don't allow acceleration when dead
	if dead:
		acceleration = Vector2.ZERO		
	
	if acceleration.length_squared() == 0 and vel_len > min_speed:
		acceleration = - velocity.normalized() * deceleration_impulse
		
	if position.x < margin:
		acceleration.x = margin_deceleration_impulse
	if position.x > max_position.x - margin:
		acceleration.x = - margin_deceleration_impulse
	
	if position.y < margin:
		acceleration.y = margin_deceleration_impulse
	if position.y > max_position.y - margin:
		acceleration.y = - margin_deceleration_impulse
	

	if acceleration.length() > max_acceleration:
		acceleration = acceleration.normalized() * max_acceleration
	
	velocity += acceleration
	
	var max_current_speed = max_speed * energy_adjustment()
	
	if velocity.length() > max_current_speed:
		velocity = velocity.normalized() * max_current_speed
	
	position += velocity * delta
	#rotation_degrees += rotation_speed * delta
	
	update_energy(-energy_usage * delta)
	
	scale_phase += scale_speed * delta
	scale = base_scale * (1 + scale_magnitude * sin(scale_phase))


func _on_Tank_area_entered(area: Area2D):
	if area.get("is_mob"):
		area.collided = true
		if area.get("is_good_mob"):
			update_energy(+energy_gain)
		if area.get("is_bad_mob"):
			update_energy(-energy_damage)
	
	if area.get("is_goal"):
		area.reached = true
		goal_reached = true
