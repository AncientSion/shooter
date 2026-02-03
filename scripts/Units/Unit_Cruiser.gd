extends Capital
class_name Cruiser

var display = "Cruiser"

func _ready():
	pass
	
func getPossibleWeapons(index):
	#type, display, turnrate, health, texture, projsize, projnumber, burst, rof, minDmg, maxDmg, deviation, speed
	match index:
		0:
			return Globals.getWeaponBase("Heavy Autocannon");
		1:
			return Globals.getWeaponBase("Medium Autocannon");
		2:
			return Globals.getWeaponBase("Medium Autocannon");
		3:
			return Globals.getWeaponBase("Medium Autocannon");
		4:
			return Globals.getWeaponBase("Heavy Autocannon");
