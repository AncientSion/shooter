extends Capital
class_name Destroyer

var display = "Destroyer"

func _ready():
	pass
	
func setStats():
	maxHealth = 150
	armor = 2
	speed = 55
	lootValue = 50
	
func getPossibleWeapons(index):
	#type, display, turnrate, health, texture, projsize, projnumber, burst, rof, minDmg, maxDmg, deviation, speed
	match index:
		0:
			return Globals.getSpecificBaseWeaponByName("Medium Autocannon");
		1:
			return Globals.getSpecificBaseWeaponByName("Medium Autocannon");
		2:
			return Globals.getSpecificBaseWeaponByName("Medium Autocannon");
		3:
			return Globals.getSpecificBaseWeaponByName("Medium Autocannon");
