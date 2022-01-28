extends TextureRect

func set_light_position(val: Vector2):
	get_material().set_shader_param("light_position", val)
