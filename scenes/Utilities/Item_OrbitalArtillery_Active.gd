extends Item_Base
class_name Item_OrbitalArtillery_Active

func _ready():
	var interval = 0.3
	var start = 0.5
	initCallMethodTrack("effector", interval, start)
	
func setQualityMods():
	return
	match quality: 
		-2:
			mods.append({"name": "Way Less Lifetime", "prop": "lifetime", "effect": 0.8, "type": "pct"})
			mods.append({"name": "Beam more narrow", "prop": "beamWidth", "effect": 0.8, "type": "pct"})
			mods.append({"name": "Slightly Less Damage", "prop": "maxDmg", "effect": 0.8, "type": "pct"})
		-1:
			mods.append({"name": "Slightly less Lifetime", "prop": "lifetime", "effect": 0.9, "type": "pct"})
		1:
			mods.append({"name": "Slightly more Lifetime", "prop": "lifetime", "effect": 1.1, "type": "pct"})
		2:
			mods.append({"name": "Way More Lifetime", "prop": "lifetime", "effect": 1.2, "type": "pct"})
			mods.append({"name": "Beam more wide", "prop": "beamWidth", "effect": 1.2, "type": "pct"})
			mods.append({"name": "Slightly more Damage", "prop": "maxDmg", "effect": 1.2, "type": "pct"})
	
func effector():
	var allTargets = get_tree().get_nodes_in_group("hostile")
	var targets = Array()
	for n in allTargets:
		if not n.isLegalTarget(): continue
		var dist = global_position.distance_to(n.global_position)
		#print("dist to ", n.display, ": ", int(dist))
		if dist < 1000:
			targets.append(n)
	
			
	var shell = Globals.SHELL.instance()
	
	shell.constructProj(result[0])
	shell.get_node("Sprites/Main").visible = false
	shell.disableTriggerCollisionNodes()
	
	for n in 1:
		var target = Globals.getRandomEntryAndRemove(targets)
		var targetPos = Vector2.ZERO
		var deviX = 100
		var deviY = 100
		
		if target == null:
			targetPos = player.global_position
			deviX = 500
			deviY = 500
		else:
			targetPos = target.getFuturePosition(result[0].lifetime)
		Globals.PROJCONT.add_child(shell)
		var devi = Vector2(Globals.rng.randi_range(-deviX, deviX), Globals.rng.randi_range(-deviY, deviY))
		
		shell.global_position = targetPos + devi
		
		var aoe_mark = Globals.AOE_MARK.instance()
		aoe_mark.construct(shell.lifetime, shell.aoe*2, shell.aoe)
		shell.add_child(aoe_mark)
