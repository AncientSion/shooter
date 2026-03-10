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
	Globals.PROJCONT.add_child(missile)
