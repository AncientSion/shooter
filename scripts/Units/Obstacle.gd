extends Base_Unit
class_name Obstacle

var display = "Obstacle"

func _ready():
	isPlayer = false
	isWeapon = false
	isObstacle = true
	faction = -1
	
func _physics_process(delta):
	pass

func process_movement(delta):
	pass
	
func addPhysCollision():
	return
