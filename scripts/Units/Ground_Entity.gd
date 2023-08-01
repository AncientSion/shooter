extends Base_Unit
class_name Ground_Entity


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func doInit():
	.doInit()
	
func _physics_process(delta):
	pass
	
func getPossibleWeapons(index):
	return false
	
func getSpawnX(viewFrom, viewTo):
	return Globals.rng.randi_range(0 + 200, Globals.WIDTH - 200)
	
func getSpawnY(viewFrom, viewTo):
	return Globals.ROADY - texDim.y/2
