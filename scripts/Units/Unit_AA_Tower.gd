extends Ground_Entity
class_name AA_Tower

var display = "AA Tower"
var behaviors = ["Guard"]

func _ready():
	sightRange = 1000
#	$Mounts/A/Sprite.hide()
	
func _physics_process(_delta):
	pass
	
func setStats():
	maxHealth = 80
	armor = 2
	lootValue = 12

func getPossibleWeapons(index):
	
#	var proc = Globals.BULLET_RED.instance()
	var proc = Globals.RAIL.instance()
	
	Globals.curScene.get_node("Refs").add_child(proc)
#func construct(init_dmgType, init_speed, init_minDmg, init_maxDmg, init_faction, init_projSize, init_projNumber = 1, init_shooter = false):
	proc.construct(0, 250, 2, 3, faction, 1)
	proc.set_physics_process(false)
	proc.disableCollisionNodes()
	
#	func construct(init_type:int, init_display:String, init_texture, init_projSize:float, init_projNumber:int, init_burst:int, init_rof:float, init_dmg, init_deviation:int, init_speed:int, init_proc:Proj_Bullet, init_procAmount:int):

	var weapon = Globals.weapon_aoe.instance()
	var dmg = {"dmgType": 0, "min": 12, "max": 16, "aoe": 75}
	weapon.construct(3, "AA Artillery", false, 1, 1, 1, 6.0, dmg, 0, 0, proc, 24, 1)
	return weapon

func isLegalTarget():
	return true
	if curTarget.global_position.y > Globals.HEIGHT - 200:
		return false
	return true
