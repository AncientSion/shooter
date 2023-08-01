extends Ground_Vehicle
class_name Jeep

var display = "Jeep"

func _ready():
	sightRange = 600
	
func setStats():
	maxHealth = 10
	armor = 0
	speed = 90
	lootValue = 3
	
func getPossibleWeapons(index):
	var weapon = Globals.getSpecificBaseWeaponByName("Light Missile");
	#weapon.steering = 24
#	weapon.makeUntargetable()
	weapon.makeInvisible()
	return weapon
