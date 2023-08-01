extends Node2D

enum missions {HOLD, SURVIVE, RAID_CONVOY_LIGHT, RAID_CONVOY_HEAVY, RAID_FLAK, PROTECT_CITY, PROTECT_CARGOHAULER, SALVAGE_CARGOHAULER}
var mission
var timerPct = 100
var main 
var virtTimeLeft = 0
var virtFullTime = 0
var deltaSumSinceLast = 0
var pick:int
var ticks = 0
var missionState:int = 0 #0 inactive 1 active 2 success 3 fail

onready var mission_hold = preload("res://scenes/Mission_Hold.tscn")

var missionUI
var missiontext
var timerLabel 
var bar
var player
var handler_spawn

#func _ready():
	
func doInit():
	name = "Handler_Mission"
	print("init ", name)
	set_physics_process(true)
	missionUI = Globals.curScene.get_node("UI/Place/TopCenter/Mission_PC")
	bar = missionUI.get_node("VBox/Progress")
	missiontext =  missionUI.get_node("VBox/Type")
	timerLabel =  missionUI.get_node("VBox/HBox/Time")
	player = Globals.PLAYER
	handler_spawn = Globals.handler_spawner
	setObjective()
		
func setObjective():
	#return
	print("setObjective()")
	var group = []
	pick = missions.values()[randi()%missions.size()]
	pick = 1
	match pick:
		0: 
			setupControlObj(5)
		1:
			setupSurviveObj(60)
		2:
			group.append({"name": "mobile_aa_light", "amount": Globals.rng.randi_range(1, 1), "target": false})
			group.append({"name": "truck_light", "amount": Globals.rng.randi_range(1, 2), "target": true})
			group.append({"name": "mobile_aa_light", "amount": Globals.rng.randi_range(1, 1), "target": false})
			group.append({"name": "truck_light", "amount": Globals.rng.randi_range(1, 2), "target": true})
			group.append({"name": "mobile_aa_light", "amount": Globals.rng.randi_range(1, 1), "target": false})
			setupRaidObj(group, 5)
		3:
			group.append({"name": "mobile_aa_light", "amount": Globals.rng.randi_range(1, 2), "target": false})
			group.append({"name": "truck_heavy", "amount": Globals.rng.randi_range(2, 3), "target": true})
			group.append({"name": "mobile_aa_light", "amount": Globals.rng.randi_range(1, 2), "target": false})
			setupRaidObj(group, 5)
		4:
			group.append({"name": "aa_tower", "amount": Globals.rng.randi_range(2, 3), "target": true})
			setupRaidObj(group, 5)
		5:
			group.append({"name": "city", "amount": Globals.rng.randi_range(1, 1), "target": true})
			setupProtectObj(group, 20)
			var attacker = [{"name": "destroyer", "amount": Globals.rng.randi_range(1, 1), "target": false}]
			setupAttacker(attacker)
		6:
			group.append({"name": "cargohauler", "amount": Globals.rng.randi_range(1, 1), "target": true})
			setupProtectObj(group, 60)
			var attacker = [{"name": "frigate", "amount": Globals.rng.randi_range(1, 1), "target": false}]
			setupAttacker(attacker)
		7:
			group.append({"name": "cargohauler", "amount": Globals.rng.randi_range(1, 1), "target": true})
			setupSalvageObj(group, 5)
			
func setupControlObj(time):
	mission = mission_hold.instance()
	missiontext.text = "Control Area"
	var w = Globals.getRandomEntry([500, 350, 200])
	var h = Globals.getRandomEntry([500, 350, 200])
	w = 600
	h = 400
	mission.doInit(Globals.WIDTH/2 - w/2, Globals.HEIGHT/2 - h/2, w, h)
	Globals.curScene.add_child(mission)
	setupObjectiveTimer(time)
	missionStart()
	#Globals.curScene.get_node("MissionTimer").paused = false
	
func setupSurviveObj(time):
	missionState = 0
	mission = load("res://scripts/Mission_Survive.gd").new()
	missiontext.text = "Survive Attack"
	Globals.curScene.add_child(mission)
	player.connect("hasWarpedIn", self, "missionStart")
	setupObjectiveTimer(time)
	#Globals.curScene.get_node("MissionTimer").paused = false
	
func setupRaidObj(unitArray, time):
	mission = load("res://scripts/Mission_ObjWithUnit.gd").new()
	var targets = 0
	var allUnits = []
	var lowestSpeed = 1000
	Globals.curScene.add_child(mission)
	disableObjectiveTimer()
	
	var dir = Globals.getRandomEntry([-1, 1])
	
	for unit in unitArray:
		for i in unit.amount:
			var object = handler_spawn.get(unit.name).instance()
			allUnits.append(object)
			Globals.curScene.addUnit("Enemy_Units", object)
			object.setHostile()
			object.setArmament()
			object.setDirection(Vector2(dir, 0))
			object.doInit()
			lowestSpeed = min(lowestSpeed, object.speed)
			if unit.target:
				targets += 1
				object.connect("objectiveDestroyed", self, "on_mission_target_destroyed")
			
	#for AA tower
	var step = 300
	var number = 4
	var positions = []
	for i in number:
		positions.append(step * (i+1))
		positions.append(-step * (i+1))
		
	for i in len(allUnits):
		#print(positions)
		var single = allUnits[i]
		single.canChangeBehavior = false
		single.speed = lowestSpeed
		var x:int
		var y:int
		if single.display == "Light Truck" or single.display == "Heavy Truck" or single.display == "Mobile AA Light":
			if single.display == "Heavy Truck" or single.display == "Light Truck":
				single.markAsTarget()
				single.addHealthBar()
				single.addHealthLabel()
				timerLabel.text = str(targets, "x ", single.display)
			x = (100 + (Globals.rng.randi_range(200, 200)*i)) * dir
			if dir == -1:
				x += Globals.WIDTH
		elif single.display == "AA Tower":
			single.markAsTarget()
			single.addHealthBar()
			single.addHealthLabel()
			timerLabel.text = str(targets, "x ", single.display)
			x = (Globals.WIDTH / 2) + Globals.getRandomEntryAndRemove(positions)
			
		y = single.getSpawnY(0, 0)
		single.position = Vector2(x, y)
		print(single.display, ": ", single.position.x)
		
	mission.amount = targets
	mission.remaining = targets
	missiontext.text = "Destroy Target"
	missionStart()
	
func setupAttacker(unitArray):
	var targets = mission.targets
	
	for unit in unitArray:
		for i in unit.amount:
			var object = handler_spawn.get(unit.name).instance()
			Globals.curScene.addUnit("Enemy_Units", object)
			object.setHostile()
			object.setArmament()
			object.forceLockOnTarget(Globals.getRandomEntry(targets))
			object.speed = object.target.speed
			object.setDirection(object.target.direction)
			var x = object.target.position.x + (400*object.direction.x*-1)
			var y:int = 0
			if object.target.position.y > Globals.HEIGHT * 0.9:
				y = object.target.position.y - Globals.rng.randi_range(500, 750)
			else:
				y = object.target.position.y + (Globals.rng.randi_range(200, 350) * Globals.getRandomEntry([-1, 1]))
			object.position = Vector2(x, y)
			object.activeBehavior = 2
			object.addHealthBar()
			object.doInit()
			object.travelTimeBase *= 2
			object.setupDelayedWarpIn(3 + i*1)
	missionStart()

func setupProtectObj(unitArray, time):
	mission = load("res://scripts/Mission_ObjWithUnit.gd").new()
	Globals.curScene.add_child(mission)
	setupObjectiveTimer(time)
	
	var targets = 0
	var allUnits = []
	
	var dir = Globals.getRandomEntry([-1, 1])
	#dir = -1
	
	for unit in unitArray:
		for i in unit.amount:
			var object = handler_spawn.get(unit.name).instance()
			allUnits.append(object)
			Globals.curScene.addUnit("Neutral_Units", object)
			mission.targets.append(object)
			object.setFriendly()
			object.setArmament()
			object.setDirection(Vector2(dir, 0))
			object.addHealthBar()
			object.doInit()
			if unit.target:
				targets += 1
				object.connect("objectiveDestroyed", self, "on_mission_target_destroyed")
			
	
	var initialX:int
	var initialY:int
	
	match mission.targets[0].display:
		"City":
			initialX = 0
			initialY = mission.targets[0].getSpawnY(0, 0)
		"Cargohauler": 
			initialX = 0 + Globals.rng.randi_range(150, 300)
			initialY = Globals.HEIGHT/2 - Globals.rng.randi_range(150, 300)
			timerLabel.text = ""
			missionState = false
			
	for i in len(allUnits):
		var single = allUnits[i]
		var x:int
		var y:int
		if single.display == "City":
			x = initialX + (Globals.rng.randi_range(150, 400)* dir)
			y = single.getSpawnY(0, 0)
		elif single.display == "Cargohauler":
			x = (initialX + ((Globals.rng.randi_range(200, 300) + 100) * i)) * dir
			y = initialY + (i*-Globals.getRandomEntry([-225, -150, 150, 225]))
			single.connect("hasWarpedIn", self, "missionStart")
			single.setupDelayedWarpIn(1 + i*0)
			
		single.position = Vector2((Globals.WIDTH / 2) + x, y)
		#print(single.position)
		
	mission.amount = targets
	mission.remaining = targets
	missiontext.text = "Protect Target"
	missionStart()

func setupSalvageObj(unitArray, time):
	mission = mission_hold.instance()
	missiontext.text = "Salvage"
	var w = Globals.getRandomEntry([500, 350, 200])
	var h = Globals.getRandomEntry([500, 350, 200])
	w = 700
	h = 300
	var pos = Vector2(Globals.WIDTH/2 + Globals.rng.randi_range(200, 600) * Globals.getRandomEntry([-1, 1]), Globals.ROADY-100)
	mission.doInit(pos.x - w/2, pos.y - h/2 - 200, w, h)
	Globals.curScene.get_node("Various").add_child(mission)
	setupObjectiveTimer(time)
	#Globals.curScene.get_node("MissionTimer").paused = false
	
	for unit in unitArray:
		for i in unit.amount:
			var object = handler_spawn.get(unit.name).instance()
			var dir = Globals.getRandomEntry([-1, 1])
			Globals.curScene.addUnit("Neutral_Units", object)
			
	#		Globals.curScene.get_node("ParallaxLayer/Foreground/Pos").add_child(object)		
	#		object.show_behind_parent = true
			
			object.setFriendly()
			object.setArmament()
			object.setDirection(Vector2(dir, 0))
			object.setWrecked()
			object.rotation_degrees = Globals.rng.randi_range(8, 20) * dir
#			object.get_node("ControlNodes").rotation = -object.rotation
			object.toggleThrusters()
	#		object.addHealthLabel()
			object.addHealthBar()
			object.doInit()
			if object.display == "Cargohauler":
				object.position = Vector2(pos.x + (200*i), pos.y + 100)
				
				for j in 4:
					var smoke_node = Globals.SMOKE.instance()
					object.get_node("EffectNodes").add_child(smoke_node)
					var smokePos = object.getPointInsideTex()
					smoke_node.position = smokePos
					
				for j in 3:
					var fire_node = Globals.FIRE.instance()
					object.get_node("EffectNodes").add_child(fire_node)
					var firePos = object.getPointInsideTex()
					fire_node.position = firePos
					
				for j in 1:
					var smoke_node = Globals.SMOKE_WIDE.instance()
					smoke_node.get_node("Particles2D").process_material.emission_box_extents.x *= 1.5
					smoke_node.get_node("Particles2D").amount *= 1.5
					Globals.curScene.get_node("Various").add_child(smoke_node)
					smoke_node.position = object.global_position + Vector2((-110 * dir), 15)
	missionStart()
				
func missionStart():
	missionState = 1

func on_mission_protect_destroyed():
	print("on_mission_protect_destroyed")
	mission.remaining -= 1
	#bar.value = (1 - (float(mission.remaining) / mission.amount))*100
	
	if (pick == missions.PROTECT_CARGOHAULER or pick == missions.PROTECT_CITY) and mission.remaining == 0:
		hasFailedMission()
	
func on_mission_target_destroyed():
	print("on_mission_target_destroyed")
	mission.remaining -= 1
	bar.value = (1 - (float(mission.remaining) / mission.amount))*100
	
func on_mission_timer_timeout():
	print("on_mission_timer_timeout")
	
func hasFailedMission():
	print("hasFailedMission")
	
	var text = "MISSION FAILED"
	missionState = 3
	timerLabel.set("text", text)
	timerLabel.set("custom_colors/font_color", Color(1, 0, 0, 1))
	Globals.addBigTextAndFade(text)	

func isMissionCompleted():
	#return falsweds
	if mission == null: return true
	if (pick == missions.RAID_CONVOY_LIGHT or pick == missions.RAID_CONVOY_HEAVY) and mission.amount and mission.remaining == 0:
		return true
#	if (pick == missions.PROTECT_CARGOHAULER or pick == missions.PROTECT_CITY) and mission.amount and mission.remaining == 0:
#		return true
	if virtFullTime > 0 and virtTimeLeft <= 0:
		return true
	return false

func setupObjectiveTimer(duration):
#	print(is_physics_processing())
	missionUI.get_node("VBox/HBox/Time").set_align(2)
	missionUI.get_node("VBox/HBox/Time2").show()
	virtTimeLeft = duration
	virtFullTime = duration
	
func disableObjectiveTimer():
	print("disableObjectiveTimer")
	missionUI.get_node("VBox/HBox/Time").set_align(1)
	missionUI.get_node("VBox/HBox/Time2").hide()
	
func _physics_process(delta):
#	print("dign")
	if mission == null or not is_instance_valid(self): return
	if missionState != 1: return
	if isMissionCompleted(): return
	
	ticks += 1
	deltaSumSinceLast += delta
	#if ticks != 10: return
	ticks = 0
	updateMissionTimeState(delta)
	
	
func updateMissionTimeState(delta):
	
	if virtFullTime > 0:
		if pick == missions.HOLD or pick == missions.SALVAGE_CARGOHAULER:
			if mission.inArea == true:
				virtTimeLeft -= deltaSumSinceLast
			else:
				virtTimeLeft += deltaSumSinceLast
				virtTimeLeft = min(virtTimeLeft, virtFullTime)
		elif pick == missions.SURVIVE or pick == missions.PROTECT_CARGOHAULER or pick == missions.PROTECT_CITY:
			virtTimeLeft -= deltaSumSinceLast
			if isMissionCompleted():
				warpMissionTargets()
		
		virtTimeLeft = max(0, virtTimeLeft)
		timerPct = virtTimeLeft / virtFullTime * 100 / 100
		
#		newEntry.get_node("value").text = "%.2f" % value
		
		
		timerLabel.text = "%.2f" % virtTimeLeft
		
#
#		var strTimeLeft = str(round((virtTimeLeft)*100)/100)
#		if len(strTimeLeft) == 1:
#			strTimeLeft += ":00"
#		strTimeLeft += " seconds left"
#		timerLabel.text = strTimeLeft
		
		bar.value = (1-timerPct)*100
		
	elif pick == missions.RAID_CONVOY_LIGHT or pick == missions.RAID_CONVOY_HEAVY or pick == missions.RAID_FLAK:
		pass

	deltaSumSinceLast = 0

func warpMissionTargets():
	for n in mission.targets:
		if n.canWarp():
			n.doWarpOut()
