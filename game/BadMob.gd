extends "res://BaseMob.gd"

var is_bad_mob = true


func _ready():
	$TrueColors.play(anim)
	$AnimatedSprite.play(anim)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var nimble_dist_2 = position.distance_squared_to(nimble.position)
	if nimble_dist_2 < nimble_range_squared:
		$TrueColors.modulate.a = smoothstep(nimble_range_squared, 0, nimble_dist_2)
	else:
		$TrueColors.modulate.a = 0
