extends Item_Passive
class_name Item_NearfieldDeflector

var bits = []

func _ready():
	pass
		
func doInit():
	addSelfDrones()
	
func addSelfDrones():
	if bits.size() > 0:
		return
		
	for stack in result[0].stacks:
		var bit = Globals.handler_spawner.get(result[0].prop).instance()
		Globals.curScene.get_node("Neutral_Units").add_child(bit)
#		func construct(init_orbit_radius, init_orbit_speed, init_orbit_radius_offset):
		bit.construct(result[0].orbit_radius, result[0].orbit_speed, TAU/result[0].stacks*(stack+1))
		bit.setOrbitTarget(targetProp)
		bit.set_armaments()
		bit.doInit()
		bit.setActive()
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
			mods.append({"name": "Way More Missiles", "prop": "amount", "effect": 1.2, "type": "pct"})
			mods.append({"name": "Way More Damage", "prop": "damage", "effect": 1.1, "type": "pct"})
			
func doTrigger():
	pass
	
func needsTarget():
	return true
	
func setItemTarget(init_target):
	targetProp = init_target
	
func doUnload():
	for bit in bits:
		bit.queue_free()
	bits = []
