extends Item_Passive
class_name Item_ResonanceDissipator

func doUse():
	if inCooldown(): return
	consumeCharge()
	cooldown = baseCooldown
	doTrigger()
	
func doTrigger():
	var missile = Globals.MISSILE.instance()
#	func construct(init_faction, init_dmgType, init_speed, init_minDmg, init_maxDmg, init_aoe, init_lifetime, init_impactForce, init_steerForce, init_projSize, init_target, init_projNumber = 1, init_shooter = null):
	missile.construct(1, 1, 0, effects[0].minDmg, effects[0].maxDmg, effects[0].aoe, 0.1, Vector2.ZERO, 0, 0, null, 1, null)
#	missile.hide()
#	missile.lifetime = 1.0
	missile.position = global_position
	missile.disableCollisionNodes()
	Globals.curScene.get_node("Projectiles").add_child(missile)
	yield(get_tree(), "physics_frame")
	missile.explode()
