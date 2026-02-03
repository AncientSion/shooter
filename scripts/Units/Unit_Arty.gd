extends Ground_Vehicle
class_name Arty

var display = "Arty"

func _ready():
	pass
	
func getPossibleWeapons(index):
	match index:
		0:
			var minDmg = 2
			var maxDmg = 3
			var speed = 125
			var recoilForce = Globals.getRecoilForce(minDmg, maxDmg, speed)
			var proc = {"type": 1, "faction": faction, "dmgType": 0, "speed": speed, "minDmg": minDmg, "maxDmg": maxDmg, "aoe": 0, "lifetime": 3.3, "projNumber": 1, "projSize": 1, "recoilForce": recoilForce}

			var weapon = Globals.getWeaponBase("Arty_Gun");
			weapon.proc = proc
			weapon.procAmount = 12
			weapon.minFireDist = 400
			return weapon
			
func getPossibleWeaponsx(index):
	var minDmg = 2
	var maxDmg = 3
	var speed = 125
	var recoilForce = Globals.getRecoilForce(minDmg, maxDmg, speed)
	var proc = {"type": 1, "faction": faction, "dmgType": 0, "speed": speed, "minDmg": minDmg, "maxDmg": maxDmg, "aoe": 0, "lifetime": 3.0, "projSize": 1, "recoilForce": recoilForce}

	var weapon = Globals.getWeaponBase("Arty_Gun");
	weapon.proc = proc
	weapon.procAmount = 18

	return weapon
