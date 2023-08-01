extends Capital
class_name Cruiser

var display = "Cruiser"

func _ready():
	pass
	
func setStats():
	maxHealth = 300
	armor = 3
	speed = 40
	lootValue = 100
	
func getPossibleWeapons(index):
	#type, display, turnrate, health, texture, projsize, projnumber, burst, rof, minDmg, maxDmg, deviation, speed
	match index:
		0:
			return Globals.getSpecificBaseWeaponByName("Heavy Autocannon");
		1:
			return Globals.getSpecificBaseWeaponByName("Medium Autocannon");
		2:
			return Globals.getSpecificBaseWeaponByName("Medium Autocannon");
		3:
			return Globals.getSpecificBaseWeaponByName("Medium Autocannon");
		4:
			return Globals.getSpecificBaseWeaponByName("Heavy Autocannon");
