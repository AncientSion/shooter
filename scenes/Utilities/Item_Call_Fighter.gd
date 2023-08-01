extends Item_Base
class_name Item_Call_Fighter

func _ready():
	var interval = 2
	var start = 1
	initCallMethodTrack("effector", interval, start)
	
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
	
func effector():
	var unit = Globals.handler_spawner.fighter.instance()
	Globals.curScene.get_node("Friendly_Units").add_child(unit)
	
	var position = Vector2(
		Globals.rng.randi_range(150, 300) * Globals.getRandomEntry([1, -1]),
		Globals.rng.randi_range(100, 175) * Globals.getRandomEntry([1, -1])
	)
	unit.position = Globals.PLAYER.position + position
	unit.lifetime = effects[0].lifetime
	unit.setFriendly()
	unit.setArmament()
	unit.setDirection()
	unit.doInit()
	unit.setInactive()
	unit.doWarpIn()
	
	var lifetimer = Timer.new()
	lifetimer.wait_time = effects[0].lifetime
	lifetimer.connect("timeout", unit, "_on_lifetime_timeout")
	unit.get_node("TimerNodes").add_child(lifetimer)
	
