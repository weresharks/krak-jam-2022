extends Node2D


var tank
var goal

export var max_speed: float = 200
export var min_speed: float = 5
export var start_speed: float = 30
export var gravity_base: float = 1000
export var min_gravity_distance_2: float = 20*20
export var longing_base: float = 0.12
export var longing_distance: float = 70
export var acceleration_impulse: float = 10
export var turning_impulse: float = 1

export var goal_detection_color: Color
export var goal_detection_range: float = 600

export var max_idle_animation_speed: float = 100

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

func set_tank(_tank):
	tank = _tank


func set_goal(_goal):
	goal = _goal


func apply_goal_modulation():
	var mod_color = Color.white

	if is_instance_valid(goal):
		var goal_distance: float = position.distance_to(goal.position)
		if goal_distance < goal_detection_range:
			var s: float = (1 - goal_distance / goal_detection_range)
			mod_color.r = lerp(mod_color.r, goal_detection_color.r, s)
			mod_color.g = lerp(mod_color.g, goal_detection_color.g, s)
			mod_color.b = lerp(mod_color.b, goal_detection_color.b, s)
			
	modulate = mod_color


var current_anim_priority: int = 0
	
func play_animation(name: String, priority: int = 0, force: bool = false):
	var current_anim = $AnimationCloud.animation
	if (name != current_anim and priority >= current_anim_priority) or force:
		$AnimationCloud.play(name)
		$AnimationCore.play(name)
		current_anim_priority = priority

func _on_anim_finished():
	current_anim_priority = 0


func apply_motion_animation(velocity):
	var speed = velocity.length()
	if $AnimationCloud.animation == "go" and speed < max_idle_animation_speed:
		play_animation("go_stop", 1)
	elif $AnimationCloud.animation == "idle" and speed > max_idle_animation_speed:
		play_animation("go_start", 1)
	
	if speed < max_idle_animation_speed:
		play_animation("idle")
	else:
		play_animation("go")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var tank_dist = position.distance_to(tank.position)
	var tank_dist_2 = tank_dist * tank_dist
	var gravity_impulse: float = 0
	if tank_dist_2 > min_gravity_distance_2:
		gravity_impulse = gravity_base / tank_dist_2
	var gravity = position.direction_to(tank.position) * gravity_impulse
	
	var longing_impulse: float = 0
	if tank_dist > longing_distance:
		longing_impulse = longing_base * (tank_dist - longing_distance)
	
	longing = position.direction_to(tank.position) * longing_impulse
	
	var acceleration = Vector2.ZERO
	
	# needed for turning/longitudal aka tank aka driving acceleration controls
#	var acceleration_map: Dictionary = calc_driving_controls_map(velocity)
	
	for key in acceleration_map.keys():
		if Input.is_action_pressed(key):
			acceleration += acceleration_map[key]
	
	if tank.dead:
		acceleration = Vector2.ZERO

	velocity += gravity + longing + acceleration
	
	var vlen: float = velocity.length()
	
	if vlen > max_speed:
		velocity = velocity.normalized() * max_speed
	elif vlen < min_speed:
		velocity = Vector2(0, -1).rotated(rotation) * min_speed

	position += velocity * delta
	rotation = Vector2(0, -1).angle_to(velocity)
	
	apply_goal_modulation()
	apply_motion_animation(velocity)


func calc_driving_controls_map(v: Vector2) -> Dictionary:
	var half_pi: float = PI / 2
	v = v.normalized()	
	return {
		"nimble_left": v.rotated(- half_pi) * turning_impulse,
		"nimble_right": v.rotated(+ half_pi) * turning_impulse,
		"nimble_forward": v * acceleration_impulse,
		"nimble_back": v * (- acceleration_impulse / 2),
	}

