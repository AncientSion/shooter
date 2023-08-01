extends ColorRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	set_shader_params()
	pass # Replace with function body.



func set_shader_params() -> void:
	var viewport_size : Vector2 = get_viewport_rect().size
	var target_size : Vector2 = get_global_rect().size
	var target_size_uv : Vector2 = target_size / viewport_size
	var target_pos : Vector2 = get_global_rect().position
	var target_pos_uv : Vector2 = target_pos / viewport_size
	
	material.set_shader_param("screen_pos", target_pos_uv)
	material.set_shader_param("screen_size", target_size_uv)
