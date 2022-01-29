extends Node

enum DIFFICULTY {EASY, NORMAL, HARD}

export var difficulty_adjustment: Dictionary = {
	DIFFICULTY.EASY: 0,
	DIFFICULTY.NORMAL: 7,
	DIFFICULTY.HARD: 20
}

export var max_difficulty: int = 42

export var mob_spawn_interval_range: Array = [5, 0.5]
export var good_mob_probability_range: Array = [1.0, 0.1]
export var mob_speed_range: Array = [10, 100]
export var energy_usage_range: Array = [0.05, 1]


var base_difficulty: int
var level: int

func start(difficulty: int):
	base_difficulty = difficulty_adjustment[difficulty]
	set_level(1)

func set_level(_level: int):
	level = _level


func get_current_difficulty() -> float:
	return float(level + base_difficulty)


func lerp_with_difficulty(value_range: Array, power: float = 1):
	return lerp(
		value_range[0], 
		value_range[1], 
		pow(clamp((get_current_difficulty() - 1) / max_difficulty, 0, 1), power)
	)


func get_mob_spawn_interval() -> float:
	return lerp_with_difficulty(mob_spawn_interval_range, 0.5)


func get_good_mob_proability() -> float:
	return lerp_with_difficulty(good_mob_probability_range, 0.1)


func get_mob_speed() -> float:
	return lerp_with_difficulty(mob_speed_range, 0.5)


func get_energy_usage() -> float:
	return lerp_with_difficulty(energy_usage_range)

