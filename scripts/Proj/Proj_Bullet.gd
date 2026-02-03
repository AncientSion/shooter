extends Proj_Base
class_name Proj_Bullet
#
#var type = 1
var tracertrigger:float = 0.1

func init():
	pass
	
func _ready():
	velocity = Vector2(1, 0).rotated(rotation)
#	$Trail.set_as_toplevel(true)
#	$Trail.points[0] = global_position
#	$Trail.points[1] = global_position
	
func _physics_process(delta):
	position += velocity * speed * delta
	
#	if tracertrigger > 0.0:
#		tracertrigger -= delta
#		if tracertrigger <= 0:
#			$Trail.show()
	
func get_class():
	return "Proj_Mace"
