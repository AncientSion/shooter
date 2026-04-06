extends Mission_Base
class_name Mission_Protect_Cargo_Hauler

func _ready():
	pass
	
func _physics_process(delta):
	pass
	
func set_base_props():
	code = "PROTECT_CARGO_HAULER"
	title = "Protect Cargo hauler"
	difficulty = 0
	reward = 0
	desc = "Protect the Cargo hauler"

func mission_final_setup_self():
	do_init(10)
	do_setup()
	
func do_process(_delta):
	pass
#	timeRemain = max(0, timeRemain - _delta)
#	timerLabel.text = "%.2f" % timeRemain
#	bar.value = (1.0 - (timeRemain / maxTime)) * 100.0
#
#	if timeRemain <= 0.0:
#		set_mission_condition_fullfilled()

func do_init(init_time):
	maxTime = init_time
	timeRemain = init_time
	remaining = amount

func do_setup():
	var target_group = []
	target_group.append({"name": "CARGO_HAULER", "amount": Globals.rng.randi_range(1, 1), "target": true})
	
	var attacker_group = []
	attacker_group.append({"name": "FRIGATE", "amount": Globals.rng.randi_range(1, 1), "target": false})
	
	setup_targets(target_group)
	setup_attackers(attacker_group)
	
func setup_targets(unitArray):
	var num_targets = 0
	var allUnits = []
	
	var dir = Globals.getRandomEntry([-1, 1])
	#dir = -1
	
	for unit in unitArray:
		for i in unit.amount:
			var target_unit = handler_s.get(unit.name).instance()
			allUnits.append(target_unit)
			Globals.curScene.add_unit_to_scene("Neutral_Units", target_unit)
			target_unit.set_friendly()
			target_unit.set_armaments()
			target_unit.set_direction(Vector2(dir, 0))
			target_unit.add_health_bar()
			target_unit.mark_as_protect()
			target_unit.doInit()
			if unit.target:
				num_targets += 1
#				object.display = "Cargohauler"
				targets.append(target_unit)
				target_unit.connect("objectiveDestroyed", self, "on_mission_target_destroyed")
	
	var initialX:int
	var initialY:int
	
	match targets[0].display:
		"City":
			initialX = 0 - (Globals.rng.randi_range(1000, 1400) * dir)
			initialY = targets[0].getSpawnY(0, 0)
		"Cargohauler": 
			initialX = 0 + Globals.rng.randi_range(150, 300)
			initialY = Globals.HEIGHT/2 - Globals.rng.randi_range(150, 300)
#			timerLabel.text = ""
			
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
			single.setup_delayed_warp_in(3 + i*3) 
			
		single.position = Vector2((Globals.WIDTH / 2) + x, y)
		
	amount = num_targets
	remaining = num_targets
	
	for n in targets:
		Globals.UI.add_target_healthbar_to_mission_bar(n)

func setup_attackers(unitArray):
	for unit in unitArray:
		for i in unit.amount:
			var attacker = handler_s.get(unit.name).instance()
			var target = Globals.getRandomEntry(targets)
			Globals.curScene.add_unit_to_scene("Enemy_Units", attacker)
			attacker.set_hostile()
			attacker.set_armaments()
			attacker.add_primary_target(target)
			attacker.stats.flee_tresh = 0.25
			attacker.connect("_has_warped_in", target, "add_primary_target", [attacker])
			target.connect("_has_warped_out", attacker, "_on_target__has_warped_out", [target])
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
				attacker.setup_delayed_warp_in(5 + i*3)
			else:
				attacker.setActive()

