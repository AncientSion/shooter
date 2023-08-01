extends Item_Base
class_name Item_BombRack

func _ready():
	var interval = 0.4
	var start = 0.2
	initCallMethodTrack("effector", interval, start)
	
func effector():
	
	for n in result:
		var devi = 0
		var proj = Globals.BOMB.instance()
		proj.constructNew(n)
		
		Globals.curScene.get_node("Projectiles").add_child(proj)
		
		proj.rotation_degrees = Globals.PLAYER.rotation_degrees + 0 + Globals.rng.randi_range(-devi, devi)
		proj.global_position = global_position
		proj.gravity_vec = Globals.BASEGRAVITY
		
func setQualityMods():
	return
