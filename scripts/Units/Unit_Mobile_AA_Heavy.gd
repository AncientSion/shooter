extends Ground_Vehicle
class_name Mobile_AA_Heavy

var display = "Mobile AA Heavy"

func _ready():
	sightRange = 1000
	
func _physics_process(delta):
	pass
	
func setStats():
	maxHealth = 30
	armor = 1
	speed = 30
	lootValue = 8

func getPossibleWeapons(index):	
	var weapon = Globals.getSpecificBaseWeaponByName("Medium Missile");
	weapon.fof = 30
	weapon.makeInvisible()
	return weapon

func isLegalTargetX(_target = null):
	#if _target: print(_target.display)
	if _target.global_position.y > Globals.HEIGHT - 400:
		print(_target.display, ": not legal")
		return false
	return true
