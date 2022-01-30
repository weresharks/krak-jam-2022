extends Node

export var level_multiplier_base: float = 2
export var energy_multiplier: float = 1
export var time_multiplier: float = 100
export var max_time: float = 600

var Difficulty
var level: int
var level_time: float = 0
var last_level_time: float
var last_level_energy: float
var last_level_score: int = 0
var total_score: int = 0

var high_score: int = 0

var victory: bool = false


func start(_difficulty):
	level = 0
	total_score = 0
	Difficulty = _difficulty


func start_level():
	level += 1
	level_time = 0
	victory = false


func end_level(energy):
	last_level_time = level_time
	last_level_energy = energy
	last_level_score = get_level_score() + get_bonus_score(energy)
	total_score += last_level_score


func end_game():
	total_score += get_level_score()
	if total_score >= high_score:
		high_score = total_score


func get_level_score():
	var score_multiplier = level_multiplier_base * Difficulty.get_current_difficulty()
	return int(level_time * score_multiplier)


func get_bonus_score(energy_left: float) -> int:
	var score_multiplier = level_multiplier_base * Difficulty.get_current_difficulty()
	var energy_score = energy_multiplier * energy_left * score_multiplier
	var time_score = clamp(1 - (level_time / max_time), 0, 1) * time_multiplier * score_multiplier
	return int(energy_score + time_score)
	

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	level_time += delta
