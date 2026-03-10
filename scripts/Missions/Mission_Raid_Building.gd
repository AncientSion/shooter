extends Mission_Base
class_name Mission_Raid_Building

func _ready():
	pass
	
func _physics_process(delta):
	pass
	
func set_base_props():
	pass

func do_init(time):
	type = "Mission_Raid_Building"
	handler_m.missiontext.text = "Destroy Target"
	time = 15.0
	maxTime = time
	timeRemain = time
	remaining = amount
	
func on_mission_target_destroyed():
	print("on_mission_target_destroyed")
	return
	remaining -= 1
	Globals.handler_mision.bar.value = (1 - (float(remaining) / amount))*100
	
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
			Globals.curScene.addUnit("Enemy_Units", object)
			object.setHostile()
			object.setArmament()
			object.setDirection(Vector2(dir, 0))
			object.look_ahead = 0
			object.doInit()
			lowestSpeed = min(lowestSpeed, object.maxSpeed)
			if unit.target:
				num_targets += 1
				targets.append(object)
				object.connect("objectiveDestroyed", self, "on_mission_target_destroyed")


	var step = 800
	var number = 5
	var positions = []
	for i in number:
		positions.append(step * (i+1))
		positions.append(-step * (i+1))
			
	for i in len(allUnits):
		var single = allUnits[i]
		single.maxSpeed = lowestSpeed
		var x:int
		var y:int
		var w = single.texDim.x

		if single.display == "AA Tower":
			single.setActive()
			single.markAsTarget()
			single.add_health_bar()
#			single.addHealthLabel()
			x = (Globals.WIDTH / 2) + Globals.getRandomEntryAndRemove(positions)
			x = (Globals.WIDTH / 2) + (i*300)
			y = single.getSpawnY(0, 0)
			single.position = Vector2(x, y)
		
	amount = num_targets
	remaining = num_targets
#	missiontext.text = "Destroy Target"
	
	for n in targets:
		handler_m.setupMissionObjectiveHealthBar(n)
	
#	setupObjectiveTimer(time)
#	missionStart()
	
#	pass

func do_process(_delta):
#	if inArea:
#		timeRemain = max(0.0, timeRemain - _delta)
#	else:
#		timeRemain = min(maxTime, timeRemain + _delta)
		
	timeRemain = max(0, timeRemain - _delta)
	timerPct = timeRemain / maxTime * 100 / 100
	
	handler_m.timerLabel.text = "%.2f" % timeRemain
	handler_m.bar.value = (1-timerPct)*100
	
	if timeRemain <= 0.0:
		do_complete_mission()
	
func do_complete_mission():
	handler_m.missionState = 2
	handler_m.missionUI.get_node("VBox/Time").hide()
	handler_m.missionUI.get_node("VBox/mission_state_label/label").text = "Mission Completed !"
	handler_m.missionUI.get_node("VBox/mission_state_label/label").show()
