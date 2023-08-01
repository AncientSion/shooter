extends Item_Passive
class_name Item_CounterbarrageSystem
	
func doUse():
	if inCooldown(): return
	consumeCharge()
	cooldown = baseCooldown
	doTrigger()
	
func setQualityMods():
	match quality: 
		-2:
			mods.append({"name": "Way Less Missiles", "prop": "amount", "effect": 0.8, "type": "pct"})
			mods.append({"name": "Way Less Damage", "prop": "damage", "effect": 0.9, "type": "pct"})
		-1:
			mods.append({"name": "Less Missiles", "prop": "amount", "effect": 0.9, "type": "pct"})
		1:
			mods.append({"name": "More Missiles", "prop": "amount", "effect": 1.1, "type": "pct"})
		2:
			mods.append({"name": "Way more Missiles", "prop": "amount", "effect": 1.2, "type": "pct"})
			mods.append({"name": "Way more Damage", "prop": "damage", "effect": 1.1, "type": "pct"})
			
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
	
	for n in amount:
		for i in result:
			var target = Globals.getRandomEntry(targets)
			var missile = Globals.MISSILE.instance()
			missile.constructNew(i)
			missile.setHomingTarget(target)
			
			missile.position = global_position
			missile.rotation_degrees = Globals.rng.randi_range(0, 359)
			missile.accel = Vector2(500, 0).rotated(missile.rotation)
			Globals.curScene.get_node("Projectiles").add_child(missile)
