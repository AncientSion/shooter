extends Ground_Vehicle
class_name Arty

var mounts = [Vector2(0, 0)]
var display = "Arty"

func _ready():
	sightRange = 1000
	
func setStats():
	pass
	
func getPossibleWeapons(index):
#type, display, turnrate, health, texture, projsize, projnumber, burst, rof, minDmg, maxDmg, deviation, speed
#	var weapon = Globals.weapon_proj.instance()
	#weapon.construct(1, "Light Machinecannon", 1, 20, false, 0.7, 1, 1, 0.2, 1, 2, 1, 450)
	
	var proc = Globals.BULLET_RED.instance()
	Globals.curScene.get_node("Refs").add_child(proc)
#func construct(init_dmgType, init_speed, init_minDmg, init_maxDmg, init_faction, init_projSize, init_projNumber = 1, init_shooter = false):
	proc.construct(0, 125, 2, 3, faction, 1)
	proc.set_physics_process(false)
	proc.disableCollisionNodes()
	
#	func construct(init_type:int, init_display:String, init_texture, init_projSize:float, init_projNumber:int, init_burst:int, init_rof:float, init_dmg, init_deviation:int, init_speed:int, init_proc:Proj_Bullet, init_procAmount:int, lifetime

	var weapon = Globals.weapon_aoe.instance()
	var dmg = {"dmgType": 0, "min": 7, "max": 9, "aoe": 50}
	weapon.construct(3, "AA Artillery", false, 1, 1, 1, 6.0, dmg, 150, 500, proc, 18, 3)
	return weapon

func isLegalTargetX():
	if curTarget.global_position.y > Globals.HEIGHT - 400:
		return false
	return true
