extends Node


export var initial_nimble_displacement: float = 60
export var initial_nimble_displacement_variation: float = 20
export var min_zoom_distance_x: float = 150
export var max_zoom_distance_x: float = 600
export var min_zoom_distance_y: float = 75
export var max_zoom_distance_y: float = 300

export var mob_margin: float = 100
export var mob_despawn_margin: float = 200

export var goal_margin: float = 20

var max_mobs = 100
var num_respawns = 0

var GoodMob: PackedScene = load("res://GoodMob.tscn")
var BadMob: PackedScene = load("res://BadMob.tscn")

var Goal: PackedScene = load("res://Goal.tscn")

export var good_mob_probability: float = 0.2

export var min_mob_spawn_distance: float = 300
var min_mob_spawn_distance_2: float

export var min_goal_spawn_distance: float = 100
var min_goal_spawn_distance_2: float


export var scene_size: Vector2 = Vector2(3000, 2000)
var viewport_size: Vector2 = Vector2.ZERO

export var show_debug = false

var mobs: Array = []

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
	add_child(m)
	update_mob(m)


func despawn_mob(m):
	mobs.erase(m)
	m.queue_free()


func update_mob(m):
	m.update_tank_pos($Tank.position)
	m.update_nimble_pos($Nimble.position)


func update_debug(distance_vector):
	$Debug/tank_pos.text = str($Tank.position)
	$Debug/nimble_pos.text = str($Nimble.position)
	$Debug/distance_vector.text = str(distance_vector)
	$Debug/mobs_count.text = str(mobs.size())
	$Debug/nimble_longing.text = str($Nimble.longing)
	$Debug/energy.text = str($Tank.energy)
	$Debug/respawns.text = str(num_respawns)


func update_debug_visibility():
	if show_debug:
		$Debug.scale = Vector2.ONE
	else:
		$Debug.scale = Vector2.ZERO

func end_game():
	game_started = false

	for m in mobs:
		despawn_mob(m)

	if goal:
		goal.queue_free()
	
	$Tank.hide()
	$Nimble.hide()


func new_game():
	game_started = true
	
	for m in mobs:
		despawn_mob(m)

	$MobTimer.start()

	$Tank.start(scene_size)
	$Tank.show()
	
	spawn_goal()
	
	var nimble_displacement_mag: float = (
		initial_nimble_displacement + 
		rand_range(-initial_nimble_displacement_variation, initial_nimble_displacement_variation)
	)
	var nimble_displacement = Vector2(0, nimble_displacement_mag).rotated(rand_range(0, 2 * PI))	
	$Nimble.update_tank_pos($Tank.position)
	$Nimble.start($Tank.position + nimble_displacement)
	$Nimble.show()


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	min_mob_spawn_distance_2 = min_mob_spawn_distance * min_mob_spawn_distance
	min_goal_spawn_distance_2 = min_mob_spawn_distance * min_mob_spawn_distance
	update_debug_visibility()
	
	new_game()


func _process(delta):
	$Nimble.update_tank_pos($Tank.position)
	
	for m in mobs:
		if m.collided:
			despawn_mob(m)
		elif not Rect2(
			Vector2.ONE * - mob_despawn_margin, scene_size + Vector2.ONE * mob_despawn_margin
		).has_point(m.position):
			despawn_mob(m)
			spawn_mob()
			num_respawns += 1
		else:
			update_mob(m)

	var distance_vector: Vector2 = ($Nimble.position - $Tank.position).abs()
	update_debug(distance_vector)
	
	if Input.is_action_just_released("debug_toggle"):
		show_debug = not show_debug
		update_debug_visibility()
	
	if not game_started:
		$ScreenShaders/Saturation.set_saturation(1)
	elif goal.reached:
		$ScreenShaders/Saturation.set_saturation(5)
		if $EndTimer.is_stopped():
			$EndTimer.start()
	else:
		$ScreenShaders/Saturation.set_saturation(clamp($Tank.energy_adjustment(), 0, 1))
	
	var nimble_rel_pos = $Nimble.position / get_viewport().size
	var nimble_uv = nimble_rel_pos - Vector2(int(nimble_rel_pos.x), int(nimble_rel_pos.y))
	$ScreenShaders/Light.set_light_position(nimble_uv)

func _on_MobTimer_timeout():
	if mobs.size() < max_mobs:
		spawn_mob()

func _on_EndTimer_timeout():
	end_game()
	$StartTimer.start()


func _on_StartTimer_timeout():
	new_game()
