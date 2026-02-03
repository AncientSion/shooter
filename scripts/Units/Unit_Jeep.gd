extends Ground_Vehicle
class_name Jeep

var display = "Jeep"

func _ready():
	pass

func _physics_process(_delta):
	pass
	
func doInit():
	.doInit()
	$Mounts/A.get_node("Weapon").scale.x = 0.7
	
func setDirection(_dirVector = false):
	pass

func getPossibleWeapons(index):
#	var weapon = Globals.getWeaponBase("Light Missile");
#	weapon.makeInvisible()
	var weapon = Globals.getWeaponBase("Light Machinegun");
#	weapon.makeInvisible()
	
	return weapon
