extends MarginContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#set_mouse_filter(2)


func _xon_mouse_entered():
	print("itementry mouse in")
#	$Sprite.material.set_shader_param("width", 3.0)
func _xon_mouse_exited():
	print("itementry mouse out")
#	$Sprite.material.set_shader_param("width", 0.0)
	
