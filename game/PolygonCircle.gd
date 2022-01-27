extends Polygon2D

export var radius = 5.0

func _draw():
	draw_circle(position, radius, Color.cyan)
