extends Item_Passive
class_name Item_CounterbarrageSystem

func _ready():
	pass
	
#func _ready():
#	var interval = 1
#	var start = 0.5
#	initCallMethodTrack("effector", interval, start)
#	result[0].shooter = self
#	result[0].beamLength = 5000#Globals.ROADY
	
func doUse():
	if inCooldown(): return
	consumeCharge()
	cooldown = baseCooldown
	doTrigger()
	
func setQualityMods():
	match quality: 
		-2:
			mods.append({"name": "Way Less Missiles", "prop": "stacks", "effect": 0.8, "type": "pct"})
			mods.append({"name": "Way Less Damage", "prop": "damage", "effect": 0.9, "type": "pct"})
		-1:
			mods.append({"name": "Less Speed", "prop": "speed", "effect": 0.9, "type": "pct"})
		1:
			mods.append({"name": "More Speed", "prop": "speed", "effect": 1.1, "type": "pct"})
		2:
			mods.append({"name": "Way More Missiles", "prop": "stacks", "effect": 1.2, "type": "pct"})
			mods.append({"name": "Way More Damage", "prop": "damage", "effect": 1.1, "type": "pct"})
			
func doTrigger():
	
	var allTargets = get_tree().get_nodes_in_group("hostile")
	var targets = Array()
	for n in allTargets:
		if not n.isLegalTarget(): continue
		var dist = global_position.distance_to(n.global_position)
		#print("dist to ", n.display, ": ", int(dist))
		if dist < 1000:
			targets.append(n)
		
	#print(targets)
#	if len(targets):
#		target = Globals.getRandomEntry(targets)
#	else: target = null
	
	for stack in result[0].stacks:
		for effect in result:
			var missile = Globals.MISSILE.instance()
			missile.constructProj(effect)
			missile.setHomingTarget(Globals.getRandomEntry(targets))
			
			missile.position = global_position
			missile.rotation_degrees = Globals.rng.randi_range(0, 359)
			missile.accel = Vector2(500, 0).rotated(missile.rotation)
			Globals.PROJCONT.add_child(missile)
