extends Node


export var initial_nimble_displacement: float = 60
export var initial_nimble_displacement_variation: float = 20
export var min_zoom_distance_x: float = 150
export var max_zoom_distance_x: float = 600
export var min_zoom_distance_y: float = 75
export var max_zoom_distance_y: float = 300

export var mob_margin: float = 100
export var mob_despawn_margin: float = 200

var max_mobs = 100
var num_respawns = 0

var GoodMob: PackedScene = load("res://GoodMob.tscn")
var BadMob: PackedScene = load("res://BadMob.tscn")

export var good_mob_probability: float = 0.2

export var min_mob_spawn_distance: float = 300
var min_mob_spawn_distance_2: float

export var scene_size: Vector2 = Vector2(3000, 2000)

export var show_debug = true

var mobs: Array = []

func update_debug_visibility():
	if show_debug:
		$Debug.scale = Vector2.ONE
	else:
		$Debug.scale = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	min_mob_spawn_distance_2 = min_mob_spawn_distance * min_mob_spawn_distance
	
	$MobTimer.start()

	$Tank.start(scene_size)
	
	var nimble_displacement_mag: float = (
		initial_nimble_displacement + 
		rand_range(-initial_nimble_displacement_variation, initial_nimble_displacement_variation)
	)
	var nimble_displacement = Vector2(0, nimble_displacement_mag).rotated(rand_range(0, 2 * PI))	
	$Nimble.update_tank_pos($Tank.position)
	$Nimble.start($Tank.position + nimble_displacement)
	
	update_debug_visibility()
	
func spawn_mob():
	var mob_scene = BadMob if randf() > good_mob_probability else GoodMob
	
	var mob_position: Vector2 = Vector2.ZERO
	for _i in range(10):
		var pos = Vector2(
			rand_range(mob_margin, scene_size.x - mob_margin),
			rand_range(mob_margin, scene_size.y - mob_margin)
		)
		if pos.distance_squared_to($Tank.position) > min_mob_spawn_distance_2:
			mob_position = pos
			break
	
	# don't spawn if we couldn't find an appropriate position after trying a few times
	if mob_position == Vector2.ZERO:
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
	
	var zoom_distance = Vector2.ONE
	
	if distance_vector.x >= min_zoom_distance_x:
		zoom_distance.x = min(distance_vector.x, max_zoom_distance_x) / min_zoom_distance_x

	if distance_vector.y >= min_zoom_distance_y:
		zoom_distance.y = min(distance_vector.y, max_zoom_distance_y) / min_zoom_distance_y
	
	var zoom: float = max(zoom_distance.x, zoom_distance.y)

	$Tank/Camera.zoom = Vector2.ONE * zoom

	update_debug(distance_vector)
	
	if Input.is_action_just_released("debug_toggle"):
		show_debug = not show_debug
		update_debug_visibility()
	
	$ScreenShaders/Saturation.set_saturation(clamp($Tank.energy_adjustment(), 0, 1))


func _on_MobTimer_timeout():
	if mobs.size() < max_mobs:
		spawn_mob()
