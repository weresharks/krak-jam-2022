extends Node


export var initial_nimble_displacement: float = 60
export var initial_nimble_displacement_variation: float = 20
export var min_zoom_distance: float = 50
export var max_zoom_distance: float = 700

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
	var zoom_distance = $Nimble.position.distance_to($Tank.position)
	
	if zoom_distance <= min_zoom_distance:
		$Tank/Camera.zoom = Vector2.ONE
	elif zoom_distance < max_zoom_distance:
		$Tank/Camera.zoom = Vector2.ONE * (zoom_distance / min_zoom_distance)

	update_debug()
