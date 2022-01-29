extends Area2D

var is_goal: bool = true
var reached: bool = false

export var scale_speed: float = 0 # PI / 3 # 0 -> disable scaling
export var scale_magnitude: float = 0.4

var base_scale: Vector2
var scale_phase: float = 0


func _ready():
	reached = false
	base_scale = scale


func _process(delta):
	scale_phase += scale_speed * delta
	scale = base_scale * (1 + scale_magnitude * sin(scale_phase))
