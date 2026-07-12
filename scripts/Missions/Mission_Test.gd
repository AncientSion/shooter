extends Mission_Base
class_name Mission_Test

const mission_time:float = 300.0
const time_until_target_arrives:float = 1.0

func _ready():
	pass
	
func _physics_process(delta):
	pass
	
func set_base_props():
	code = "TEST"
	title = "Strike Light Ground Convoy"
	difficulty = 0
	reward = 0
	desc = "Ambush the lightly armored supply convoy before it reaches enemy lines.\nEliminate all escorts and destroy the cargo trucks with minimal collateral damage"

func mission_final_setup_self():
	do_init(mission_time)
	do_setup()
	
	Globals.PLAYER.connect("_has_warped_in", self, "do_start_mission")

func do_init(init_time):
	maxTime = init_time
	timeRemain = init_time
	remaining = amount
	
func do_setup():
	var attacker_group = []
	attacker_group.append({"name": "FIGHTER", "amount": Globals.rng.randi_range(1, 1), "target": false})
	setup_attackers(attacker_group)
	
func setup_attackers(unitArray):
	for unit in unitArray:
		for i in unit.amount:
			var attacker = handler_s.get(unit.name).instance()
			var target = Globals.getRandomEntry(targets)
			Globals.curScene.add_unit_to_scene("Enemy_Units", attacker)
			attacker.set_hostile()
			attacker.do_init_unit()
			attacker.set_armaments()
			attacker.set_direction(Vector2.RIGHT)
#			attacker.maxSpeed = 0
			
			var x:int = Globals.WIDTH/2
			var y:int = Globals.HEIGHT/2
			
			var pos = Globals.PLAYER.global_position + Vector2(-350, -150) + Vector2(-0, -200)
			pos.x += 400 * i
			
			attacker.position = pos
			attacker.add_health_bar()
			
			if attacker.can_warp_in():
				attacker.setup_delayed_warp_in(time_until_target_arrives+1)
			else:
				attacker.setActive()

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
