extends Ground_Entity
class_name AA_Tower

var display = "AA Tower"

func _ready():
	pass
	
func _physics_process(_delta):
	pass
	
func doInit():
#	maxSmoke = 10
	.doInit()
	
func getPossibleWeapons(index):
	match index:
		0:
			var minDmg = 2
			var maxDmg = 3
			var speed = 125
			var recoilForce = Globals.getRecoilForce(minDmg, maxDmg, speed)
			var proc = {"type": 1, "faction": faction, "dmgType": 0, "speed": speed, "minDmg": minDmg, "maxDmg": maxDmg, "aoe": 20, "lifetime": 0.5, "projNumber": 1, "projSize": 1, "recoilForce": recoilForce}

			var weapon = Globals.getWeaponBase("Arty_Gun");
			weapon.proc = proc
			weapon.procAmount = 12
			weapon.minFireDist = 200
			return weapon
		1:
			return Globals.getWeaponBase("Flak")

func isLegalTarget():
	return true
	if curTarget.global_position.y > Globals.HEIGHT - 200:
		return false
	return true
	
func get_dmg_gfx_scale():
	return rand_range(0.8, 1.4)
