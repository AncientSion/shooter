extends MarginContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_mouse_entered():
#	print("mouse in")
	get_node("CC/PC").add_stylebox_override("panel", Globals.YELLOW)
#	UI_node.get_node("CC/PC").add_stylebox_override("panel", Globals.RED)	
	#$Sprite.material.set_shader_param("width", 3.0)
	
func _on_mouse_exited():
#	print("mouse out")
	get_node("CC/PC").add_stylebox_override("panel", Globals.BLACK)
