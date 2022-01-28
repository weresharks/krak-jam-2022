extends "res://BaseMob.gd"

var is_good_mob = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	._process(delta)
	var nimble_dist_2 = position.distance_squared_to(nimble.position)
	if nimble_dist_2 < nimble_range_squared:
		$TrueColors.visible = true
		$Polygon2D.visible = false
	else:
		$TrueColors.visible = false
		$Polygon2D.visible = true
