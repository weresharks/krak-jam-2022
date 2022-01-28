extends Node


export var initial_nimble_displacement: float = 60
export var initial_nimble_displacement_variation: float = 20
export var min_zoom_distance_x: float = 150
export var max_zoom_distance_x: float = 600
export var min_zoom_distance_y: float = 75
export var max_zoom_distance_y: float = 300

export var num_mobs: int = 100
export var mob_margin: int = 100

var max_mobs = 100

var any_mob_scene: PackedScene = load("res://BaseMob.tscn")
var good_mob_scene: PackedScene = load("res://GoodMob.tscn")
var bad_mob_scene: PackedScene = load("res://BadMob.tscn")

var good_mob_probability: float = 0.2

export var scene_size: Vector2 = Vector2(3000, 2000)

export var show_debug = true

var tank_pos: Vector2
var nimble_pos: Vector2
var mobs: Array = []

func update_debug_visibility():
	if show_debug:
		$Debug.scale = Vector2.ONE
	else:
		$Debug.scale = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	$MobTimer.start()

	$Tank.start(scene_size)
	tank_pos = $Tank.position
	
	var nimble_displacement_mag: float = (
		initial_nimble_displacement + 
		rand_range(-initial_nimble_displacement_variation, initial_nimble_displacement_variation)
	)
	var nimble_displacement = Vector2(0, nimble_displacement_mag).rotated(rand_range(0, 2 * PI))	
	$Nimble.update_tank_pos(tank_pos)
	$Nimble.start(tank_pos + nimble_displacement)
	
	nimble_pos = $Nimble.position

	update_debug_visibility()
	
func spawn_mob():
	var mob_scene = bad_mob_scene if randf() > good_mob_probability else good_mob_scene
	var mob = mob_scene.instance()
	mobs.append(mob)
	mob.position = Vector2(
		rand_range(mob_margin, scene_size.x - mob_margin),
		rand_range(mob_margin, scene_size.y - mob_margin)
	)
	add_child(mob)
	mob.update_tank_pos(tank_pos)
	mob.update_nimble_pos(nimble_pos)
	

func update_debug(distance_vector):
	$Debug/tank_pos.text = str($Tank.position)
	$Debug/nimble_pos.text = str($Nimble.position)
	$Debug/distance_vector.text = str(distance_vector)
	$Debug/mobs_count.text = str(mobs.size())
	$Debug/nimble_longing.text = str($Nimble.longing)
	$Debug/energy.text = str($Tank.energy)

func _process(delta):
	$Nimble.update_tank_pos($Tank.position)
	
	for m in mobs:
		if m.collided:
			mobs.erase(m)
			m.queue_free()
		else:
			m.update_tank_pos($Tank.position)
			m.update_nimble_pos($Nimble.position)
	
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


func _on_MobTimer_timeout():
	if mobs.size() < max_mobs:
		spawn_mob()
