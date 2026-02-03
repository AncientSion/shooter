extends Ground_Vehicle
class_name Mobile_AA_Light

var display = "Mobile AA Light"

func _ready():
	pass
	
func getPossibleWeapons(index):
	var weapon = Globals.getWeaponBase("Light Autocannon")
#	weapon.makeInvisible()missi
	return weapon
