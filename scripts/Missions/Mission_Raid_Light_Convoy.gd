extends Mission_Base
class_name Mission_Raid_Light_Convoy

func _ready():
	pass
	
func _physics_process(delta):
	pass
	
func set_base_props():
	code = "RAID_CONVOY_LIGHT"
	title = "Strike Light Ground Convoy"
	difficulty = 0
	reward = 0
	desc = "Ambush the lightly armored supply convoy before it reaches enemy lines.\nEliminate all escorts and destroy the cargo trucks with minimal collateral damage"

func mission_final_setup_self():
	do_init(60)
	
	var group = []
	group.append({"name": "MOBILE_AA_LIGHT", "amount": Globals.rng.randi_range(1, 1), "target": false})
	group.append({"name": "TRUCK_LIGHT", "amount": Globals.rng.randi_range(1, 2), "target": true})
	group.append({"name": "MOBILE_AA_LIGHT", "amount": Globals.rng.randi_range(1, 1), "target": false})
	group.append({"name": "TRUCK_LIGHT", "amount": Globals.rng.randi_range(1, 2), "target": true})
	group.append({"name": "MOBILE_AA_LIGHT", "amount": Globals.rng.randi_range(1, 1), "target": false})
	do_setup(group)
	
	Globals.PLAYER.connect("_has_warped_in", self, "do_start_mission")
	

func do_init(init_time):
	maxTime = init_time
	timeRemain = init_time
	remaining = amount
	
func do_setup(unitArray):
	var num_targets:int = 0
	var allUnits = []
	var lowestSpeed:int = 1000
	
	var dir = Globals.getRandomEntry([-1, 1])
	dir = -1
	var startX:int
	if dir == 1:
		startX = 0
	else: startX = Globals.WIDTH
	
	for unit in unitArray:
		for i in unit.amount:
			var object = handler_s.get(unit.name).instance()
			allUnits.append(object)
			Globals.curScene.add_unit_to_scene("Enemy_Units", object)
			object.do_init_unit()
			object.set_hostile()
			object.set_armaments()
			object.set_direction(Vector2(dir, 0))
			object.look_ahead = 0
			object.doInit()
			lowestSpeed = min(lowestSpeed, object.maxSpeed)
			if unit.target:
				num_targets += 1
				targets.append(object)
				object.connect("objectiveDestroyed", self, "on_mission_target_destroyed")
		
	for i in len(allUnits):
		var single = allUnits[i]
		single.maxSpeed = lowestSpeed
		var x:int
		var y:int
		var w = single.texDim.x
		startX += (120 + w/2) * dir
		single.position = Vector2(startX, single.getSpawnY(0, 0))
		if single.display == "Light Truck" or single.display == "Heavy Truck" or single.display == "Mobile AA Light":
			single.setActive()
			single.get_node("SM").canChangeState = false
			if single.display == "Heavy Truck" or single.display == "Light Truck":
				single.mark_as_target()
				single.add_health_bar()
#				single.addHealthLabel()
		
	amount = num_targets
	remaining = num_targets
		
	for n in targets:
		Globals.UI.add_target_healthbar_to_mission_bar(n)

func do_process(_delta):
#	if inArea:
#		timeRemain = max(0.0, timeRemain - _delta)
#	else:
#		timeRemain = min(maxTime, timeRemain + _delta)
		
	timeRemain = max(0, timeRemain - _delta)
	timerPct = timeRemain / maxTime * 100 / 100
	
	timerLabel.text = "%.2f" % timeRemain
	bar.value = (1-timerPct)*100
	
	if timeRemain <= 0.0:
		set_mission_condition_success()
