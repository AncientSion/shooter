extends Item_Base
class_name Item_MissilePod

func _ready():
	var interval = 0.2
	var start = 0.2
	initCallMethodTrack("effector", interval, start)
	
func setQuality():
	return
	
	
	
func setQualityMods():
	return
#	match quality: 
#		-2:
#			mods.append({"name": "Way Less AoE", "prop": "aoe", "effect": 0.85, "type": "pct"})
#			mods.append({"name": "Way Less Damage", "prop": "maxDmg", "effect": 0.85, "type": "pct"})
#			mods.append({"name": "More cooldown", "prop": "cooldown", "effect": 1.1, "type": "pct"})
#		-1:
#			mods.append({"name": "Slightly less effective", "prop": "effectiveness", "effect": 0.9, "type": "pct"})
#		1:
#			mods.append({"name": "Slightly more effective", "prop": "effectiveness", "effect": 1.1, "type": "pct"})
#		2:
#			mods.append({"name": "Way more AoE", "prop": "aoe", "effect": 1.5, "type": "pct"})
#			mods.append({"name": "Way more Damage", "prop": "maxDmg", "effect": 1.5, "type": "pct"})
#			mods.append({"name": "Less cooldown", "prop": "cooldown", "effect": 0.9, "type": "pct"})


func effector():
	#print("launcheffectorMissiles")
	for n in result:
		var proj = Globals.MISSILE.instance()
		var deviation = 10
		var devi = Globals.rng.randi_range(-deviation, deviation)
		proj.constructNew(n)
		
		Globals.curScene.get_node("Projectiles").add_child(proj)
		proj.rotation_degrees = global_rotation_degrees + Globals.rng.randi_range(-devi, devi)
		proj.position = global_position + (Vector2(20, 0).rotated(global_rotation))
