extends Ground_Vehicle
class_name Mobile_AA_Heavy

var display = "Mobile AA Heavy"

func _ready():
	pass
	
func _physics_process(delta):
	pass

func getPossibleWeapons(index):
	var weapon = Globals.getWeaponBase("Medium Missile Burst");
	weapon.fof = 60
	weapon.vLaunch = true
#	weapon.makeInvisible()
	return weapon
