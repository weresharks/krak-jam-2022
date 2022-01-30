extends CanvasLayer


var stages: Array

var current_stage = 0

var started: bool = false

var StartTimer

func start(GameStats, _StartTimer):
	StartTimer = _StartTimer
	
	current_stage = 0
	
	stages = [
		[$level_completed],
		[$label_time, $time],
		[$label_energy, $energy],
		[$label_score, $score],
		[$label_total_score, $total_score],
	]

	$Timer.start()
	
	$level_completed.text = "Level " + str(GameStats.level) + " Completed"
	$time.text = str(int(GameStats.last_level_time))
	$energy.text = str(int(GameStats.last_level_energy))
	$score.text = str(int(GameStats.last_level_score))
	$total_score.text = str(int(GameStats.total_score))
	started = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _input(event):
	if not started:
		return

	if event is InputEventKey and event.pressed:
		started = false
		
		for s in stages:
			for l in s:
				l.hide()
		
		StartTimer.start()


func _on_Timer_timeout():
	for l in stages[current_stage]:
		l.show()
	current_stage += 1
	if current_stage < len(stages):
		$Timer.start()
