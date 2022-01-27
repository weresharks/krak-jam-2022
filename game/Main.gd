extends Node


export var initial_nimble_displacement: float = 60
export var initial_nimble_displacement_variation: float = 20
export var min_zoom_distance_x: float = 150
export var max_zoom_distance_x: float = 1000
export var min_zoom_distance_y: float = 75
export var max_zoom_distance_y: float = 500

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	$Tank.start(Vector2(3000, 800))
	var tank_pos: Vector2 = $Tank.position
	
	var nimble_displacement_mag: float = (
		initial_nimble_displacement + 
		rand_range(-initial_nimble_displacement_variation, initial_nimble_displacement_variation)
	)
	var nimble_displacement = Vector2(0, nimble_displacement_mag).rotated(rand_range(0, 2 * PI))	
	$Nimble.update_tank_pos(tank_pos)
	$Nimble.start(tank_pos + nimble_displacement)

func update_debug():
	$Debug/tank_pos.text = str($Tank.position)
	$Debug/nimble_pos.text = str($Nimble.position)

func _process(delta):
	$Nimble.update_tank_pos($Tank.position)
	
	var distance_vector: Vector2 = ($Nimble.position - $Tank.position).abs()
	
	var zoom_distance = Vector2.ONE
	
	if distance_vector.x >= min_zoom_distance_x and distance_vector.x < max_zoom_distance_x:
		zoom_distance.x = distance_vector.x / min_zoom_distance_x

	if distance_vector.y >= min_zoom_distance_y and distance_vector.y < max_zoom_distance_y:
		zoom_distance.y = distance_vector.y / min_zoom_distance_y
	
	var zoom: float = max(zoom_distance.x, zoom_distance.y)

	$Tank/Camera.zoom = Vector2.ONE * zoom

	update_debug()
