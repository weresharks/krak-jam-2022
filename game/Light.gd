extends TextureRect

func set_light_position(val: Vector2):
	get_material().set_shader_param("light_position", val)

func set_light2_position(val: Vector2):
	get_material().set_shader_param("light2_position", val)

func set_light2_softness(val: float):
	get_material().set_shader_param("SOFTNESS2", val)
