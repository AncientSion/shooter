extends Item_Base
class_name Item_Call_Frigate

func _ready():
	var interval = 2
	var start = 1
	initCallMethodTrack("effector", interval, start)
	
func setQualityMods():
#	return
	match quality: 
		-2:
			mods.append({"name": "Way Less Duration", "prop": "lifetime", "effect": 0.8, "type": "pct"})
		-1:
			mods.append({"name": "Less Duration", "prop": "lifetime", "effect": 0.9, "type": "pct"})
		1:
			mods.append({"name": "More Duration", "prop": "lifetime", "effect": 1.1, "type": "pct"})
		2:
			mods.append({"name": "Way More Duration", "prop": "lifetime", "effect": 1.2, "type": "pct"})
	
func effector():
	var unit = Globals.handler_spawner.frigate.instance()
	Globals.curScene.get_node("Friendly_Units").add_child(unit)
	
	var position = Vector2(
		Globals.rng.randi_range(150, 300) * Globals.getRandomEntry([1, -1]),
		Globals.rng.randi_range(100, 175) * Globals.getRandomEntry([1, -1])
	)
	
	unit.position = Globals.PLAYER.position + position
	unit.position.y = clamp(unit.position.y, 1000, Globals.HEIGHT - 1000)
	unit.set_friendly()
	unit.set_armaments()
	unit.set_direction()
	unit.lifetime = result[0].lifetime
	unit.doInit()
	unit.add_health_bar()
#	unit.set_inactive()
	unit.setup_delayed_warp_in(0.1)
