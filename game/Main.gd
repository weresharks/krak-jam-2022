extends Node


export var initial_nimble_displacement: float = 60
export var initial_nimble_displacement_variation: float = 20
export var min_zoom_distance_x: float = 150
export var max_zoom_distance_x: float = 600
export var min_zoom_distance_y: float = 75
export var max_zoom_distance_y: float = 300
export var is_zoom_enabled: bool = false

export var mob_margin: float = 100
export var mob_despawn_margin: float = 200

export var goal_margin: float = 20

var difficulty: int = 1

var max_mobs = 100
var num_respawns = 0

var GoodMob: PackedScene = load("res://GoodMob.tscn")
var BadMob: PackedScene = load("res://BadMob.tscn")

var Goal: PackedScene = load("res://Goal.tscn")

export var good_mob_probability: float = 0.2

export var min_mob_spawn_distance: float = 200
var min_mob_spawn_distance_2: float

export var min_goal_spawn_distance: float = 800
var min_goal_spawn_distance_2: float


export var scene_size: Vector2 = Vector2(3000, 2000)
var viewport_size: Vector2 = Vector2.ZERO

export var show_debug = false

export var base_tank_light_softness: float = 0.4
export var tank_light_softness_mag: float = 0.1
export var tank_light_softness_speed: float = PI / 4
var tank_light_softness_phase: float = 0

var goal_reached_brightening: float = 1

var min_energy_saturation: float = 0.3


var mobs: Array = []
var mob_speed: float

var goal

var game_started = false


func find_spawn_point(origin: Vector2, spawn_range_squared: float, margin: float, retries: int = 10):
	var spawn_point = null
	
	for _i in range(retries):
		var pos = Vector2(
			rand_range(margin, scene_size.x - margin),
			rand_range(margin, scene_size.y - margin)
		)
		if pos.distance_squared_to(origin) > spawn_range_squared:
			spawn_point = pos
			break

	return spawn_point


func spawn_goal():
	var goal_position: Vector2 = find_spawn_point(
		$Tank.position, min_goal_spawn_distance_2, goal_margin, 100
	)

	goal = Goal.instance()
	goal.position = goal_position
	add_child(goal)


func spawn_mob():
	var mob_scene = BadMob if randf() > good_mob_probability else GoodMob
	var mob_position = find_spawn_point($Tank.position, min_mob_spawn_distance_2, mob_margin)
		
	# don't spawn if we couldn't find an appropriate position after trying a few times
	if not mob_position:
		return
	
	var m = mob_scene.instance()
	mobs.append(m)
	m.position = mob_position
	m.max_speed = mob_speed	
	add_child(m)
	update_mob(m)
	
	var anims = ["v1", "v2", "v3"]
	m.set_anim(anims[randi() % 3])


func despawn_mob(m):
	mobs.erase(m)
	m.queue_free()


func update_mob(m):
	m.set_tank($Tank)
	m.set_nimble($Nimble)


func update_debug(distance_vector):
	$Debug/tank_pos.text = str($Tank.position)
	$Debug/nimble_pos.text = str($Nimble.position)
	$Debug/distance_vector.text = str(distance_vector)
	$Debug/mobs_count.text = str(mobs.size())
	$Debug/nimble_longing.text = str($Nimble.longing)
	$Debug/energy.text = str($Tank.energy)
	$Debug/respawns.text = str(num_respawns)
	if is_instance_valid(goal):
		$Debug/goal_pos.text = str(goal.position)
	
	$Debug/level.text = str($GameStats.level)
	$Debug/level_time.text = str($GameStats.level_time)
	$Debug/level_score.text = str($GameStats.get_level_score())
	$Debug/total_score.text = str($GameStats.total_score)
	$Debug/high_score.text = str($GameStats.high_score)
	
	$Debug/difficulty.text = str($Difficulty.get_current_difficulty())
	$Debug/mob_spawn_interval.text = str($Difficulty.get_mob_spawn_interval())
	$Debug/good_mob.text = str($Difficulty.get_good_mob_proability())
	$Debug/mob_speed.text = str($Difficulty.get_mob_speed())
	$Debug/energy_usage.text = str($Difficulty.get_energy_usage())


func update_debug_visibility():
	if show_debug:
		$Debug.scale = Vector2.ONE
	else:
		$Debug.scale = Vector2.ZERO

func end_level(victory: bool):
	game_started = false
	if victory:
		$GameStats.end_level($Tank.energy)
	else:
		$GameStats.end_game()
		Global.last_game_score = $GameStats.total_score
		Global.high_score = $GameStats.high_score

	for m in mobs:
		despawn_mob(m)

	if goal:
		goal.queue_free()
	
	$Tank.play_animation("idle")
	$Tank.hide()
	$Nimble.hide()
	$MobTimer.stop()

	if victory:
		$LevelSummary.start($GameStats, $StartTimer)
	else:
		transition_to_title()

func transition_to_title():
	$SceneTransition.transition()
	$MusicTransition.transition()

func new_level():
	game_started = true
	$GameStats.start_level()
	$Difficulty.set_level($GameStats.level)

	$ScreenShaders/Light.modulate.a = 1
	
	for m in mobs:
		despawn_mob(m)
	
	# difficulty settings
	$MobTimer.wait_time = $Difficulty.get_mob_spawn_interval()
	good_mob_probability = $Difficulty.get_good_mob_proability()
	mob_speed = $Difficulty.get_mob_speed()
	
	$MobTimer.start()

	$Tank.start(scene_size)
	$Tank.energy_usage = $Difficulty.get_energy_usage()
	$Tank.show()
	$ScreenShaders/Light.show()
	
	spawn_goal()

	var nimble_displacement_mag: float = (
		initial_nimble_displacement + 
		rand_range(-initial_nimble_displacement_variation, initial_nimble_displacement_variation)
	)
	var nimble_displacement = Vector2(0, nimble_displacement_mag).rotated(rand_range(0, 2 * PI))	
	$Nimble.set_tank($Tank)
	$Nimble.set_goal(goal)
	$Nimble.start($Tank.position + nimble_displacement)
	$Nimble.show()
	
	for i in range($Difficulty.get_initial_mob_spawns()):
		spawn_mob()


func new_game():
	$Difficulty.start(difficulty)
	$GameStats.start($Difficulty)
	
	new_level()


func goal_reached() -> bool:
	return is_instance_valid(goal) and goal.reached


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	min_mob_spawn_distance_2 = min_mob_spawn_distance * min_mob_spawn_distance
	min_goal_spawn_distance_2 = min_mob_spawn_distance * min_mob_spawn_distance
	update_debug_visibility()
	difficulty = Global.difficulty_level
	
	if Global.high_score > 0:
		$GameStats.high_score = Global.high_score
	
	new_game()


func _process(delta):
	for m in mobs:
		if m.collided:
			despawn_mob(m)
		elif not Rect2(
			Vector2.ONE * - mob_despawn_margin, scene_size + Vector2.ONE * mob_despawn_margin
		).has_point(m.position):
			despawn_mob(m)
			spawn_mob()
			num_respawns += 1

	var distance_vector: Vector2 = ($Nimble.position - $Tank.position).abs()
	
	var zoom_distance = Vector2.ONE
	
	if distance_vector.x >= min_zoom_distance_x:
		zoom_distance.x = min(distance_vector.x, max_zoom_distance_x) / min_zoom_distance_x

	if distance_vector.y >= min_zoom_distance_y:
		zoom_distance.y = min(distance_vector.y, max_zoom_distance_y) / min_zoom_distance_y
	
	var zoom: float = 1
	
	if not $Tank.dead and is_zoom_enabled:
		zoom = max(zoom_distance.x, zoom_distance.y)
	else:
		zoom = 1

	$Tank/Camera.zoom = Vector2.ONE * zoom

	update_debug(distance_vector)
	
	if Input.is_action_just_released("debug_toggle"):
		show_debug = not show_debug
		update_debug_visibility()
	
	if not game_started:
		if goal_reached():
			$ScreenShaders/Saturation.set_saturation(5)
			
		else:
			$ScreenShaders/Saturation.set_saturation(1)
	else:
		if goal_reached() or $Tank.dead:
			init_restart(goal_reached())
		else:
			$ScreenShaders/Saturation.set_saturation(lerp(min_energy_saturation, 1.0, $Tank.energy_adjustment()))
	
	var nimble_uv = ($Nimble.position - ($Tank.position + $Tank/Camera.position)) / get_viewport().size + Vector2.ONE / 2
	$ScreenShaders/Light.set_light_position(nimble_uv)
	$ScreenShaders/Light.set_light2_position(Vector2.ONE * 0.5 - $Tank/Camera.position / get_viewport().size)
	$ScreenShaders/Light.set_light2_softness(
		base_tank_light_softness + sin(tank_light_softness_phase) * tank_light_softness_mag * $Tank.energy_adjustment()
	)
	tank_light_softness_phase += tank_light_softness_speed * delta
	
	if goal_reached():
		$ScreenShaders/Light.modulate.a -= goal_reached_brightening * delta
	
func init_restart(victory: bool):
	game_started = false
	$GameStats.victory = victory
	if victory:
		$Tank.hide()
		$Nimble.hide()
		$ScreenShaders/Light.hide()
		goal.play_end_animation()
	
	if $EndTimer.is_stopped():
		$EndTimer.start()	
	

func _on_MobTimer_timeout():
	if mobs.size() < max_mobs:
		spawn_mob()

func _on_EndTimer_timeout():
	end_level($GameStats.victory)


func _on_StartTimer_timeout():
	if $GameStats.victory:
		new_level()
	else:
		new_game()
