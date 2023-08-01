extends Ground_Vehicle
class_name Mobile_AA_Light

var display = "Mobile AA Light"

func _ready():
	sightRange = 500
	
func setStats():
	maxHealth = 25
	armor = 1
	speed = 60
	lootValue = 10
	
func getPossibleWeapons(index):
	var weapon = Globals.getSpecificBaseWeaponByName("Light Autocannon")
	weapon.makeInvisible()
	return weapon
