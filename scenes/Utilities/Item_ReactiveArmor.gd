extends Item_Passive
class_name Item_ReactiveArmor

func doUse():
	if inCooldown(): return
	consumeCharge()
	cooldown = baseCooldown
	doTrigger()
	
func setQualityMods():
	match quality: 
		-2:
			mods.append({"name": "Way Less AoE", "prop": "aoe", "effect": 0.85, "type": "pct"})
			mods.append({"name": "Way Less Damage", "prop": "maxDmg", "effect": 0.85, "type": "pct"})
			mods.append({"name": "More cooldown", "prop": "cooldown", "effect": 1.1, "type": "pct"})
		-1:
			mods.append({"name": "Slightly less effective", "prop": "effectiveness", "effect": 0.9, "type": "pct"})
		1:
			mods.append({"name": "Slightly more effective", "prop": "effectiveness", "effect": 1.1, "type": "pct"})
		2:
			mods.append({"name": "Way More AoE", "prop": "aoe", "effect": 1.5, "type": "pct"})
			mods.append({"name": "Way More Damage", "prop": "maxDmg", "effect": 1.5, "type": "pct"})
			mods.append({"name": "Less cooldown", "prop": "cooldown", "effect": 0.9, "type": "pct"})
	
func doTrigger():
	print("trigger armor")

	var missile = Globals.MISSILE.instance()
	missile.constructProj(result[0])
	missile.position = global_position
	missile.lifetime = 0.01
	missile.disableTriggerCollisionNodes()
	Globals.PROJCONT.add_child(missile)
	
	Globals.add_shockwave_at(global_position)
