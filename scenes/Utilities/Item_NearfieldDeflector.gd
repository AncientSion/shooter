extends Item_Passive
class_name Item_NearfieldDeflector

var bits = []

func _ready():
	pass
		
func doInit():
	for n in effects[0].amount:
		var bit = Globals.handler_spawner.get(effects[0].prop).instance()
		Globals.curScene.get_node("Various").add_child(bit)
#		func construct(init_orbit_radius, init_orbit_speed, init_orbit_radius_offset):
		bit.construct(effects[0].orbit_radius, effects[0].orbit_speed, TAU/effects[0].amount*(n+1))
		bit.setOrbitTarget(curTarget)
		bit.setArmament()
		bit.doInit()
		bits.append(bit)
		
func doUse():
	return
	if inCooldown(): return
	consumeCharge()
	cooldown = baseCooldown
	doTrigger()
	
func setQualityMods():
	return
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
	pass
	
func canBeOutOutBounds():
	return true
	
func needsTarget():
	return true
	
func setItemTarget(init_target):
	target = init_target
	
func doUnloadBits():
	for bit in bits:
		bit.queue_free()
	bits = []
