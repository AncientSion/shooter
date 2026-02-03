extends Proj_Missile
class_name Proj_Torp

func _ready():
	pass

func constructProj(weapon):
	.constructProj(weapon)
	accelLimit = speed/3

func get_class():
	return "Proj_Torp"
