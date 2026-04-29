extends Node2D
class_name Handler_Mission

enum missions {CONTROL, SURVIVE, RAID_CONVOY_LIGHT, RAID_CONVOY_HEAVY, RAID_FLAK, PROTECT_CITY, PROTECT_CARGOHAULER, SALVAGE_CARGOHAULER, BOSS_A, BLANK}
var mission_node:Map_Node = null
var mission
var timerPct = 100
var main 
var virtTimeLeft = 0
var virtFullTime = 0
var deltaSumSinceLast = 0
var pick:int
var timeSinceLast:float = 0.0
var missionState:int = 0 #0:inactve, 1:active, 2:success, 3:fail

#onready var mission_base = preload("res://scenes/Missions/Mission_Base.tscn")
#onready var mission_control_area = preload("res://scenes/Missions/Mission_Base.tscn")
#onready var mission_raid_cargo_hauler = preload("res://scripts/Missions/Mission_Base.gd")
#onready var mission_raid_convoy_light = preload("res://scripts/Missions/Mission_Base.gd")
#onready var mission_survive_time = preload("res://scripts/Missions/Mission_Base.gd")

onready var mission_base = ""
onready var mission_control_area = ""
onready var mission_raid_cargo_hauler = ""
onready var mission_raid_convoy_light = ""
onready var mission_survive_time = ""

var missionUI
var missiontext
var timerLabel 
var bar
var player
var handler_spawn
var missions_new:Array

var mission_dict:Dictionary

func mission_loader():
	mission_dict = get_mission_dict()
	for n in mission_dict:
		mission_dict[n]["scene"] = load(mission_dict[n]["scene_url"])
	
func get_mission_dict():
	return {
		"mission_control_area":
		{
			"scene_url": "res://scenes/Missions/Mission_Base.tscn",
			"script_url": "res://scripts/Missions/Mission_Control_Area.gd",
			"scene": null,
		},
		"mission_survive_time":
		{
			"scene_url": "res://scenes/Missions/Mission_Base.tscn",
			"script_url": "res://scripts/Missions/Mission_Survive_Time.gd",
			"scene": null,
		},
		"mission_raid_convoy_light":
		{
			"scene_url": "res://scenes/Missions/Mission_Base.tscn",
			"script_url": "res://scripts/Missions/Mission_Raid_Light_Convoy.gd",
			"scene": null,
		},
		"mission_protect_cargo_hauler":
			{
			"scene_url": "res://scenes/Missions/Mission_Base.tscn",
			"script_url": "res://scripts/Missions/Mission_Protect_Cargo_Hauler.gd",
			"scene": null,
		},
	}

		
#	print(mission_dict.keys())
#	print(mission_dict.keys().size())

func get_mission_by_name(mission_name:String = ""):
	if mission_name != "":
		return setup_mission(mission_dict[mission_name])
	else:
		print("fallback")
		return get_random_mission()
	
func get_random_mission():
	return get_mission_by_name("mission_survive_time")
	var pick:String = mission_dict.keys().pick_random()
	return setup_mission(mission_dict[pick])	

func setup_mission(mission_dict):
	var logic;
	var mission = mission_dict["scene"].instance()

	logic = load(mission_dict["script_url"]).new()
	logic.set_base_props()
	logic.print_props()
	mission.set_mission_logic(logic)
	
	mission.logic.do_init_mission(Globals.handler_mission, Globals.handler_spawner)
	mission.logic.set_base_props()
	mission.logic.do_setup_mission()
	return mission

func load_missions():
#	missions_new = [
##		mission_base, 
#		mission_control_area,
#		mission_survive_time,
#		mission_raid_convoy_light,
#		mission_raid_cargo_hauler
#	]

	var missions_new_x = [
		{"code": "CONTROL_AREA", "title": "Control Designated Area", "difficulty": 0, "reward": 0, "desc": "Secure the fortified zone and eliminate all hostiles.\nHold position until reinforcements arrive."},
		{"code": "SURVIVE", "title": "Survive Interception Attempt", "difficulty": 0, "reward": 0, "desc": "Enemy forces are hunting you—defend your position until extraction.\n Stay alive at all costs."},
		{"code": "RAID_CONVOY_LIGHT", "title": "Strike Light Ground Convoy", "difficulty": 0, "reward": 0, "desc": "Ambush the lightly armored supply convoy before it reaches enemy lines.\nEliminate all escorts and destroy the cargo trucks with minimal collateral damage"},
	#	{"code": "RAID_CONVOY_HEAVY", "title": "Strike Heavy Ground Convoy", "desc": "Assault the heavily defended armored convoy carrying high-value munitions.\nNeutralize tank escorts and disable the lead vehicle to halt the column."},
	#	{"code": "RAID_FLAK", "title": "Raid Flak Emplacements", "desc": "Obliterate anti-aircraft batteries threatening allied air operations.\nPrioritize radar units to blind their tracking systems before demolishing the guns"},
	#	{"code": "PROTECT_CITY", "title": "Protect Civilian Areas", "desc": "Defend the civilian cities from attacks.\nCivilian casualties will reduce your payout."},
	#	{"code": "PROTECT_CARGOHAULER", "title": "Protect the Cargo Hauler", "desc": "Escort the slow-moving hauler to its destination.\nRepel boarding attempts and ambushes."},
	#	{"code": "SALVAGE_CARGOHAULER", "title": "Salvage Cargo from Crashed Dropship", "desc": "Recover supplies from the wreckage under enemy fire.\nMove quickly before reinforcements arrive."},
	##	{"code": "BOSS_A", "title": "Boss A", "desc": "long_text_boss"},
	##	{"code": "BLANK", "title": "Blank", "desc": "long_text_blank"},
	]

func _physics_process(delta):
	pass
#	if missionState == 1:
#		mission_node.mission_class.logic.do_process(delta)
	
func do_bare_setup():
	print("do_bare_setup ", name)
	name = "Handler_Mission"
	player = Globals.PLAYER
	handler_spawn = Globals.handler_spawner
	load_missions()
	mission_loader()
	
func do_enable():
	print("do_enable ", name)
	set_physics_process(true)
	
func do_disable():
	print("do_disable ", name)
	set_physics_process(false)	
	
func x_connect_mission_ui_in_game():
	missionUI = Globals.curScene.get_node("UI/Place/TopCenter/Mission_PC")
	bar = missionUI.get_node("VBox/Progress")
	missiontext =  missionUI.get_node("VBox/Type")
	timerLabel =  missionUI.get_node("VBox/Time/timeStr")
	
func get_start_mission():
	return get_random_mission()
#	var dict =  {"code": "START", "title": "START", "difficulty": 0, "reward": 0,  "desc": "START"}
#	return Mission.new(dict)
	
func get_end_mission():
	return get_random_mission()
#	var dict =  {"code": "END", "title": "END", "difficulty": 0, "reward": 0, "desc": "END"}
#	return Mission.new(dict)
	

func set_obj():
	Globals.UI.set_main_text("")
	var group = []
	pick = missions.values()[randi() % missions.size()-1]
	pick = Globals.rng.randi_range(0, 7)
	pick = 4
	if pick > 9:
		pick = pick - 3
	print("set_obj: ", missions.keys()[pick])
	missionState = 0
#	pick = 8
	match pick:
		0: 
			setup_control_area_mission(5)
		1:
			setup_survive_time_mission(20)
		2:
			group.append({"name": "MOBILE_AA_LIGHT", "amount": Globals.rng.randi_range(1, 1), "target": false})
			group.append({"name": "TRUCK_LIGHT", "amount": Globals.rng.randi_range(1, 2), "target": true})
			group.append({"name": "MOBILE_AA_LIGHT", "amount": Globals.rng.randi_range(1, 1), "target": false})
			group.append({"name": "TRUCK_LIGHT", "amount": Globals.rng.randi_range(1, 2), "target": true})
			group.append({"name": "MOBILE_AA_LIGHT", "amount": Globals.rng.randi_range(1, 1), "target": false})
			setup_raid_objective(group, 0)
#			setupRaidObj(group, 0)
		3:
			group.append({"name": "MOBILE_AA_LIGHT", "amount": Globals.rng.randi_range(2, 2), "target": false})
			group.append({"name": "TRUCK_HEAVY", "amount": Globals.rng.randi_range(2, 2), "target": true})
			group.append({"name": "MOBILE_AA_LIGHT", "amount": Globals.rng.randi_range(2, 2), "target": false})
			setup_raid_objective(group, 0)
#			setupRaidObj(group, 0)
		4:
			group.append({"name": "AA_TOWER", "amount": Globals.rng.randi_range(1, 1), "target": true})
			setup_raid_building_objective(group, 0)
#			setupRaidBuildingObjective(group, 0)
		5:
			group.append({"name": "CITY", "amount": Globals.rng.randi_range(2, 2), "target": true})
			setupProtectObj(group, 10)
			var attacker = [{"name": "BOMBER", "amount": Globals.rng.randi_range(1, 1), "target": false}]
#			var attacker = [{"name": "frigate", "amount": Globals.rng.randi_range(1, 1), "target": false}]
#			var attacker = [{"name": "heli_light", "amount": Globals.rng.randi_range(1, 1), "target": false}]
			setupAttacker(attacker)
		6:
			group.append({"name": "CARGO_HAULER", "amount": Globals.rng.randi_range(1, 1), "target": true})
#			group.append({"name": "frigate", "amount": Globals.rng.randi_range(1, 1), "target": true})
			setupProtectObj(group, 10)
#			return
			var attacker = [{"name": "FRIGATE", "amount": Globals.rng.randi_range(1, 1), "target": false}]
#			var attacker = [{"name": "fighter", "amount": Globals.rng.randi_range(1, 1), "target": false}]
			setupAttacker(attacker)
		7:
			group.append({"name": "CARGO_HAULER", "amount": Globals.rng.randi_range(1, 1), "target": true})
			setupSalvageObj(group, 5)
		8:
			var boss = [{"name": "BOSS", "amount": Globals.rng.randi_range(1, 1), "target": true}]
#			group.append({"name": "heli_light", "amount": Globals.rng.randi_range(3, 3), "target": false})
#			setupBossObj(boss, group, 0.0)
		9:
#			group.append({"name": "fighter", "amount": 3, "target": false})
#			group.append({"name": "drone_shotgun", "amount": 3, "target": false})
#			group.append({"name": "drone_kamikaze", "amount": 3, "target": false})
#			setupBossObj(group)
			setupBlank(group)
			
	if pick != 19:
		Globals.handler_spawner.do_enable()
		
func do_start_mission():
	pass
			
func setup_control_area_mission(time):
	mission = mission_control_area.instance()
	Globals.curScene.get_node("Various").add_child(mission)
	mission.do_init(time)
	
	var w = 900 * 1.0
	var h = 600 * 1.0
#	mission.doInit(Globals.WIDTH/2 - w/2, Globals.HEIGHT/2 - h/2, w, h)
	mission.do_setup(Globals.WIDTH/2, Globals.HEIGHT/2, w, h)
#	setupObjectiveTimer(time)
	do_start_mission()
	#Globals.curScene.get_node("MissionTimer").paused = false
	
func setup_survive_time_mission(time):
	mission = mission_survive_time.instance()
	Globals.curScene.get_node("Various").add_child(mission)
	mission.do_init(time)
	mission.do_setup()
	do_start_mission()
	
func setup_raid_objective(unitArray, time):
	mission = mission_base.instance()
	mission.set_script(load("res://scripts/Mission_Raid.gd"))
	Globals.curScene.get_node("Various").add_child(mission)
	mission.do_init(time)
	mission.do_setup(unitArray)
	do_start_mission()
	
func setup_raid_building_objective(unitArray, time):
	mission = mission_base.instance()
	mission.set_script(load("res://scripts/Mission_Raid_Building.gd"))
	Globals.curScene.get_node("Various").add_child(mission)
	mission.do_init(time)
	mission.do_setup(unitArray)
	do_start_mission()

func setupRaidObj(unitArray, time):
	mission = load("res://scripts/Mission_ObjWithUnit.gd").new()
	var targets = 0
	var allUnits = []
	var lowestSpeed = 1000
	Globals.curScene.add_child(mission)
	
	var dir = Globals.getRandomEntry([-1, 1])
	dir = -1
	var startX:int
	if dir == 1:
		startX = 0
	else: startX = Globals.WIDTH
	
	for unit in unitArray:
		for i in unit.amount:
			var object = handler_spawn.get(unit.name).instance()
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
				targets += 1
				mission.targets.append(object)
				object.connect("objectiveDestroyed", self, "on_mission_target_destroyed")
		
	for i in len(allUnits):
		#print(positions)
		var single = allUnits[i]
#		single.speed = lowestSpeed
		single.maxSpeed = lowestSpeed
		var x:int
		var y:int
		if single.display == "Light Truck" or single.display == "Heavy Truck" or single.display == "Mobile AA Light":
			single.get_node("SM").canChangeState = false
			single.setActive()
			if single.display == "Heavy Truck" or single.display == "Light Truck":
				single.mark_as_target()
				single.add_health_bar()
				single.addHealthLabel()
				timerLabel.text = str(targets, "x ", single.display)
			var w = single.texDim.x
			startX += (120 + w/2) * dir
		single.position = Vector2(startX, single.getSpawnY(0, 0))
		if dir == 1:
			single.moveTarget = Vector2(Globals.WIDTH, 0)
		else: single.moveTarget = Vector2(1, 0)
		
	mission.amount = targets
	mission.remaining = targets
	missiontext.text = "Destroy Target"
	
	for n in mission.targets:
		setupMissionObjectiveHealthBar(n)
	
	setupObjectiveTimer(time)
	do_start_mission()
	
func setupMissionObjectiveHealthBar(target):
	pass

func setupRaidBuildingObjective(unitArray, time):
	mission = load("res://scripts/Mission_ObjWithUnit.gd").new()
	var targets = 0
	var allUnits = []
	Globals.curScene.add_child(mission)
	
#	print("setupRaidBuildingObjective")
	
	for unit in unitArray:
		for i in unit.amount:
			var object = handler_spawn.get(unit.name).instance()
			allUnits.append(object)
			Globals.curScene.add_unit_to_scene("Enemy_Units", object)
			object.do_init_unit()
			object.set_hostile()
			object.set_armaments()
			object.doInit()
			if unit.target:
				targets += 1
				mission.targets.append(object)
				object.connect("objectiveDestroyed", self, "on_mission_target_destroyed")
			
	#for AA tower
	var step = 800
	var number = 5
	var positions = []
	for i in number:
		positions.append(step * (i+1))
		positions.append(-step * (i+1))
		
	for i in len(allUnits):
		var single = allUnits[i]
		var x:int
		var y:int
		if single.display == "AA Tower":
			single.setActive()
			single.mark_as_target()
			single.add_health_bar()
			single.addHealthLabel()
			timerLabel.text = str(targets, "x ", single.display)
			x = (Globals.WIDTH / 2) + Globals.getRandomEntryAndRemove(positions)
			x = (Globals.WIDTH / 2) + (i*300)
			y = single.getSpawnY(0, 0)
			single.position = Vector2(x, y)
		
	mission.amount = targets
	mission.remaining = targets
	missiontext.text = "Destroy Target"
	
	for n in mission.targets:
		setupMissionObjectiveHealthBar(n)
	
	setupObjectiveTimer(time)
	do_start_mission()
	

#	var attacker = [{"name": "FRIGATE", "amount": Globals.rng.randi_range(1, 1), "target": false}]

func setupAttacker(unitArray):
	var targets = mission.targets
	
	for unit in unitArray:
		for i in unit.amount:
			var attacker = handler_spawn.get(unit.name).instance()
			var target = Globals.getRandomEntry(targets)
			Globals.curScene.add_unit_to_scene("Enemy_Units", attacker)
			attacker.do_init_unit()
			attacker.set_hostile()
			attacker.set_armaments()
			attacker.add_primary_target(target)
			attacker.stats.flee_tresh = 0.25
			attacker.connect("_has_warped_in", target, "add_primary_target", [attacker])
			target.connect("_has_warped_out", attacker, "_on_target_has_warped_out", [target])
#			attacker.speed = target.speed
			attacker.set_direction(target.direction)
#			print(attacker.direction.x)
			var x:int = 0
			var y:int = 0
				
			if target.position.y > Globals.HEIGHT * 0.9:
				y = target.position.y - Globals.rng.randi_range(500, 750)
#				y = target.position.y - Globals.rng.randi_range(200, 350)
			else:
				y = target.position.y + (Globals.rng.randi_range(200, 350) * Globals.getRandomEntry([-1, 1]))
				
			match attacker.display:
				"Fighter":
					x = target.position.x + (700 * -target.direction.x)
				"Helicopter_Light":
					x = target.position.x + (700 * -target.direction.x)
				"Bomber":
					x = target.position.x + (1200 * -target.direction.x)
					y = target.position.y - 400
				"Frigate":
					x = target.position.x + (600 * -attacker.direction.x)
					attacker.stats.can_withdraw = true
					attacker.stats.canCrash = false
			
#			print(target.position)
			attacker.position = Vector2(x, y)
#			print(attacker.position)
			attacker.add_health_bar()
			attacker.doInit()
			attacker.avoidValues["Player"] = 0.0
			attacker.init_as_attacker()
			
			if attacker.can_warp_in():
				attacker.setup_delayed_warp_in(3 + i*3)
			else:
				attacker.setActive()


func setupProtectObj(unitArray, time):
#	group.append({"name": "CARGO_HAULER", "amount": Globals.rng.randi_range(1, 1), "target": true})
	mission = load("res://scripts/Mission_ObjWithUnit.gd").new()
	Globals.curScene.add_child(mission)
	
	var targets = 0
	var allUnits = []
	
	var dir = Globals.getRandomEntry([-1, 1])
	#dir = -1
	
	for unit in unitArray:
		for i in unit.amount:
			var object = handler_spawn.get(unit.name).instance()
			allUnits.append(object)
			Globals.curScene.add_unit_to_scene("Neutral_Units", object)
			object.do_init_unit()
			object.set_friendly()
			object.set_armaments()
			object.set_direction(Vector2(dir, 0))
			object.add_health_bar()
			object.mark_as_protect()
			object.doInit()
			if unit.target:
				targets += 1
#				object.display = "Cargohauler"
				mission.targets.append(object)
				object.connect("objectiveDestroyed", self, "on_mission_target_destroyed")
	
	var initialX:int
	var initialY:int
	
	match mission.targets[0].display:
		"City":
			initialX = 0 - (Globals.rng.randi_range(1000, 1400) * dir)
			initialY = mission.targets[0].getSpawnY(0, 0)
		"Cargohauler": 
			initialX = 0 + Globals.rng.randi_range(150, 300)
			initialY = Globals.HEIGHT/2 - Globals.rng.randi_range(150, 300)
			timerLabel.text = ""
			
	for i in len(allUnits):
		var single = allUnits[i]
		var x:int
		var y:int
		if single.display == "City":
			x = initialX + ((Globals.rng.randi_range(1100, 1500) * i) * dir)
			y = single.getSpawnY(0, 0)
#			single.get_node("Mounts/A/Weapon/ControlNodes/ShieldBar").offset.x = -20 * dir
#			single.get_node("Mounts/C/Weapon/ControlNodes/ShieldBar").offset.x = +20 * dir
#			single.get_node("ControlNodes/HealthBar/ProgressBar").rect_min_size += Vector2(50, 0)
#	shield.add_shield_bar()
#	shield.scaleBar("shieldbar", 0.5)
#			single.setup_delayed_warp_in(3 + i*3) 
		elif single.display == "Cargohauler":
			x = (initialX + ((Globals.rng.randi_range(200, 300) + 100) * i)) * dir
			y = initialY + (i*-Globals.getRandomEntry([-225, -150, 150, 225]))
			single.connect("_has_warped_in", self, "do_start_mission")
			single.setup_delayed_warp_in(1 + i*3) 
			
		single.position = Vector2((Globals.WIDTH / 2) + x, y)
		
	mission.amount = targets
	mission.remaining = targets
	missiontext.text = "Protect Target"
	setupObjectiveTimer(time)
	
	for n in mission.targets:
		setupMissionObjectiveHealthBar(n)
	
	do_start_mission()

func setupSalvageObj(unitArray, time):
	mission = mission_control_area.instance()
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
			Globals.curScene.add_unit_to_scene("Neutral_Units", object)
			object.do_init_unit()
			object.set_friendly()
			object.set_armaments()
			object.set_direction(Vector2(dir, 0))
			object.setWrecked()
			object.rotation_degrees = Globals.rng.randi_range(8, 20) * dir
			object.toggleThrusters()
	#		object.addHealthLabel()
			object.add_health_bar()
			object.doInit()
			if object.display == "Cargohauler":
				object.position = Vector2(pos.x + (200*i), pos.y + 100)
				object.position = Vector2(pos.x - w/2, pos.y + 100)
				
				var scale = 1.0
				for j in 4:
					object.add_fire_smoke_fx(scale, 0.0)
					
				for j in 1:
					var smoke_node = Globals.SMOKE_WIDE.instance()
#					print("ding")
					var smokeTrailLength = 100
#					smoke_node.get_node("Particles2D").process_material = smoke_node.get_node("Particles2D").process_material.duplicate()
					smoke_node.get_node("Particles2D").process_material.emission_box_extents.x = smokeTrailLength
					smoke_node.get_node("Particles2D").amount = smokeTrailLength * 1.7
#					print(smoke_node.lget_node("Particles2D").amount)
#					print(smoke_node.get_node("Particles2D").process_material.emission_box_extents.x)
					Globals.curScene.get_node("Various").add_child(smoke_node)
					smoke_node.position = object.global_position + Vector2((-smokeTrailLength * dir), 15)
	do_start_mission()
	
func setupBossObj(unitArray, escortArray, time):
#	Globals.curScene.get_node("UI").hideMissionUI()
	var mainTarget
	for entry in unitArray:
		for i in entry.amount:
			var unit = handler_spawn.get(entry.name).instance()
			mainTarget = unit
			Globals.curScene.add_unit_to_scene("Enemy_Units", unit)
			unit.do_init_unit()
			unit.set_hostile()
			unit.set_armaments()
			unit.add_health_bar()
			unit.doInit()
			unit.position = Vector2(Globals.WIDTH/2, Globals.HEIGHT) + Vector2(0, -700)
			unit.setup_delayed_warp_in(1)
	
	if escortArray.size():
		var interval = 360 / escortArray[0].amount
		var current = 0
		for entry in escortArray:
			for i in entry.amount:
				var unit = handler_spawn.get(entry.name).instance()
				Globals.curScene.add_unit_to_scene("Enemy_Units", unit)
				unit.do_init_unit()
				unit.set_hostile()
				unit.set_armaments()
				unit.doInit()
				unit.setup_delayed_warp_in(3)
				unit.global_position = mainTarget.global_position + Vector2(1, 0).rotated(deg2rad(current)) * 300
				current += interval
				
#	mission.amount = targets
#	mission.remaining = targets
	missiontext.text = "Destroy Target"
	setupObjectiveTimer(time)
	setupMissionObjectiveHealthBar(mainTarget)
	
	do_start_mission()
			
func setupBlank(unitArray):
	Globals.curScene.get_node("UI").hideMissionUI()
	if unitArray.size():
		for entry in unitArray:
			for i in entry.amount:
				var unit = handler_spawn.get(entry.name).instance()
				Globals.curScene.add_unit_to_scene("Enemy_Units", unit)
				unit.do_init_unit()
				unit.set_hostile()
				unit.set_armaments()
				unit.add_health_bar()
				unit.doInit()
				unit.setActive()
#				unit.position = Vector2(Globals.WIDTH/2, Globals.HEIGHT) + Vector2(0, -700) + Vector2(randi() % 150, randi() % 150)
				unit.position = Vector2(Globals.WIDTH/2, Globals.HEIGHT/2) + Vector2(Globals.rng.randi_range(-200, 200), Globals.rng.randi_range(-200, 200))
#				print(unit.position)
				
#				randi() % 100     # Returns random integer between 0 and 99
#randi() % 100 + 1 # Returns random integer between 1 and 100

	
	
func on_mission_timer_timeout():
	print("on_mission_timer_timeout")

func is_mission_completed():
	if mission == null: return true
	if (pick == missions.RAID_CONVOY_LIGHT or pick == missions.RAID_CONVOY_HEAVY) and mission.amount and mission.remaining == 0:
		missionState = 2
	if virtFullTime > 0 and virtTimeLeft <= 0:
		missionState = 2
		return true
	return false

func setupObjectiveTimer(duration):
#	return
	if duration <= 0:
		missionUI.get_node("VBox/Time").hide()
		missionUI.get_node("VBox/Progress").hide()
	else:
		missionUI.get_node("VBox/Time").show()
		missionUI.get_node("VBox/Progress").show()
		virtTimeLeft = duration
		virtFullTime = duration
	
	
func updateMissionTimeState(delta):
	if virtFullTime > 0:
		if pick == missions.HOLD or pick == missions.SALVAGE_CARGOHAULER:
			if mission.inArea == true:
				virtTimeLeft -= deltaSumSinceLast
			else:
				virtTimeLeft += deltaSumSinceLast
				virtTimeLeft = min(virtTimeLeft, virtFullTime)
		#elif pick == missions.SURVIVE or pick == missions.PROTECT_CARGOHAULER or pick == missions.PROTECT_CITY:
		else:
			virtTimeLeft -= deltaSumSinceLast
			if is_mission_completed():
				warpMissionTargets()
		
		virtTimeLeft = max(0, virtTimeLeft)
		timerPct = virtTimeLeft / virtFullTime * 100 / 100
		
#		newEntry.get_node("value").text = "%.2f" % value
		
		
		timerLabel.text = "%.2f" % virtTimeLeft
		bar.value = (1-timerPct)*100
		
#
#		var strTimeLeft = str(round((virtTimeLeft)*100)/100)
#		if len(strTimeLeft) == 1:
#			strTimeLeft += ":00"
#		strTimeLeft += " seconds left"
#		timerLabel.text = strTimeLeft
		
		
	elif pick == missions.RAID_CONVOY_LIGHT or pick == missions.RAID_CONVOY_HEAVY or pick == missions.RAID_FLAK:
		pass

	deltaSumSinceLast = 0

func warpMissionTargets():
	for n in mission.targets:
		if n.canWarp:
			n.warp_out_phase_one()

func terminate_remains_on_mission_scene_end():
	print("terminate_remains_on_mission_scene_end")
	if mission_node != null:
		Globals.remove_poi_marker(mission_node)
		mission_node = null
		Globals.UI.reset_mission_sub_ui()
