extends Item_Passive
class_name Item_ResonanceDissipator

func doUse():
	if inCooldown(): return
	consumeCharge()
	cooldown = baseCooldown
	doTrigger()
	
func doTrigger():
	var missile = Globals.MISSILE.instance()
	missile.constructProj(result[0])
	missile.position = global_position
	missile.lifetime = 0.01
	missile.disableTriggerCollisionNodes()
	Globals.curScene.get_node("Projectiles").add_child(missile)
#	yield(get_tree(), "physics_frame")
#	missile.explode()
