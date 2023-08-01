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
			mods.append({"name": "Way more AoE", "prop": "aoe", "effect": 1.5, "type": "pct"})
			mods.append({"name": "Way more Damage", "prop": "maxDmg", "effect": 1.5, "type": "pct"})
			mods.append({"name": "Less cooldown", "prop": "cooldown", "effect": 0.9, "type": "pct"})
	
func doTrigger():
	var missile = Globals.MISSILE.instance()
#	func construct(init_faction, init_dmgType, init_speed, init_minDmg, init_maxDmg, init_aoe, init_lifetime, init_impactForce, init_steerForce, init_projSize, init_target, init_projNumber = 1, init_shooter = null):
	missile.construct(0, 1, 0, effects[0].minDmg, effects[0].maxDmg, effects[0].aoe, 0.1, Vector2.ZERO, 0, 0, null, 1, null)
#	missile.hide()
#	missile.lifetime = 1.0
	missile.position = global_position
	missile.disableCollisionNodes()
	Globals.curScene.get_node("Projectiles").add_child(missile)
	yield(get_tree(), "physics_frame")
	missile.explode()
