extends Area2D

export var max_speed: float = 100
export var min_speed: float = 10
export var max_speed_spontaneous: float = 20
export var spontaneous_acceleration_impulse: float = 0.2
export var acceleration_impulse: float = 3
export var deceleration_impulse: float = 0.3
export var margin_deceleration_impulse: float = 10
export var max_acceleration: float = 5
export var scale_speed: float = 0 # PI / 10 # 0 -> disable scaling
export var scale_magnitude: float = 0.3

export var camera_offset_factor: float = 0.2

export var energy_scaling_min: float = 0.6
export var energy_opacity_min: float = 0.2


var velocity = Vector2.ZERO
var margin = 20
var max_position: Vector2
var base_scale: Vector2
var scale_phase: float = 0

export var start_energy: float = 100
var energy: float
var max_energy: float = 200
var energy_nominal: float = 100
var energy_usage: float = 0.1
var energy_damage: float = 20
var energy_gain: float = 30

var acceleration_map: Dictionary

var dead: bool
var goal_reached: bool

export var goalReachedSound: AudioStream
export (Array, AudioStream) var damageSounds
export (Array, AudioStream) var powerUpSounds
export var max_cutoff_freq: float = 10_000


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
		if $AnimationCloud.animation != "death_decay":
			play_animation("death_decay", 3, true)
	else:
		update_energy_feedback()

func energy_adjustment():
	var adj = energy / energy_nominal
	return adj

func update_energy_feedback():
	var ea = energy_adjustment()
	var scale = clamp(lerp(energy_scaling_min, 1.0, ea), 0, 1)
	var opacity = clamp(lerp(energy_opacity_min, 1.0, ea), 0, 1)
	
	update_music_cutoff(scale)
	
	$AnimationCore.scale = Vector2.ONE * scale
	$AnimationPupil.scale = Vector2.ONE * scale
	$AnimationCore.modulate.a = opacity
	
func update_music_cutoff(scale: float):
	var bus_id = AudioServer.get_bus_index("Music")
	var low_pass_filter = AudioServer.get_bus_effect(bus_id, 0)
	low_pass_filter.set_cutoff(max_cutoff_freq * scale)
	
var current_anim_priority: int = 0
	
func play_animation(name: String, priority: int, force: bool = false):
	var current_anim = $AnimationCloud.animation
	if (name != current_anim and priority >= current_anim_priority) or force:
		$AnimationCloud.play(name)
		$AnimationCore.play(name)
		$AnimationPupil.play(name)
		current_anim_priority = priority

func rotate_go_anim(rotation_a: float, rotation_v: float):
	if $AnimationCloud.animation == "go":
		$AnimationCore.rotation = rotation_a
		$AnimationPupil.rotation = rotation_a
		$AnimationCloud.rotation = rotation_v
	else:
		$AnimationCloud.rotation = 0
		$AnimationCore.rotation = 0
		$AnimationPupil.rotation = 0

func _on_anim_finished():
	current_anim_priority = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var acceleration = Vector2.ZERO
	
	for key in acceleration_map.keys():
		if Input.is_action_pressed(key):
			acceleration += acceleration_map[key]
	
	if energy > 0:
		if acceleration == Vector2.ZERO:
			play_animation("idle", 1)
		else:
			play_animation("go", 1)
	
	rotate_go_anim(Vector2.UP.angle_to(acceleration), Vector2.UP.angle_to(velocity))
	
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
	
	var max_current_speed = max_speed * clamp(energy_adjustment(), 0.33, 2)
	
	if velocity.length() > max_current_speed:
		velocity = velocity.normalized() * max_current_speed
	
	position += velocity * delta
	
	update_energy(-energy_usage * delta)
	
	scale_phase += scale_speed * delta
	scale = base_scale * (1 + scale_magnitude * sin(scale_phase))
	
	$Camera.position = velocity * camera_offset_factor

func _on_Tank_area_entered(area: Area2D):
	if area.get("is_mob"):
		area.collided = true
		if area.get("is_good_mob"):
			update_energy(+energy_gain)
			play_animation("power_up", 3, true)
			$SoundPlayer.play_random_sound(powerUpSounds, true)
		if area.get("is_bad_mob"):
			update_energy(-energy_damage)
			play_animation("damage", 3, true)
			$SoundPlayer.play_random_sound(damageSounds, true)
	
	if area.get("is_goal"):
		area.reached = true
		goal_reached = true
		$SoundPlayer.play_sound(goalReachedSound)
