extends TextureRect

func set_saturation(val: float):
	get_material().set_shader_param("saturation", val)
