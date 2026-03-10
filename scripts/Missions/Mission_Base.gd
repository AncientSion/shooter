extends Node2D
class_name Mission_Base

var type:String = "Mission_Base"
var target_indicator:Target_Indicator = null
var targets = []
var mission
var timerPct = 100
var main 
var virtTimeLeft = 0
var virtFullTime = 0
var deltaSumSinceLast = 0
var pick:int
var timeSinceLast:float = 0.0
var missionState:int = 0 #0 inactive 1 active 2 success 3 fail

var timeRemain:float =  0.0
var maxTime:float = 0.0

var amount:int = 0
var remaining:int = 0

var handler_m:Node = null
var handler_s:Node = null

func _ready():
	pass
	
func _physics_process(delta):
	pass
	
func do_init(thandime):
	pass
	
func do_init_mission(handler_mi, handler_sp):
	handler_m = handler_mi
	handler_s = handler_sp
	
func do_process(_delta):
	pass

func get_class():
	return str("get_class: ", type)
	
var code: String
var title: String
var difficulty: int
var reward: int
var desc: String
var unit_data = []
#
#func _init(dict):
#	code = dict.code
#	title = dict.title
#	difficulty = dict.difficulty
#	reward = dict.reward
#	desc = dict.desc
	
func do_setup_mission():
	unit_data = handler_s.get_raw_unit_data_for_mission()
	set_mission_difficulty()
	set_mission_reward()
	set_mission_enemies()
#		for n in unit_data:
#			print(n)
		
func set_mission_difficulty():
	difficulty = Globals.rng.randi_range(-2, 2)
	
func set_mission_reward():
	reward = Globals.rng.randi_range(-1, 1)
	
func set_mission_enemies():
	var legal_units = []
	
	match code:
		"HOLD":
			legal_units = ["FIGHTER", "HELI_LIGHT"]
		"SURVIVE":
			legal_units = ["FIGHTER", "HELI_HEAVY", "FRIGATE"]
		"RAID_CONVOY_LIGHT":
			legal_units = ["FIGHTER", "HELI_LIGHT"]
		"CONTROL_AREA":
			legal_units = ["FIGHTER", "HELI_LIGHT"]
			
	for entry in legal_units:
		for unit in unit_data:
			if entry == unit.const:
				unit.legal = true
				break
	
func print_props():
	print("code: ", code)
	print("title: ", title)
	print("difficulty: ", difficulty)
	print("reward: ", reward)
	print("desc: ", desc)
	for n in unit_data:
		print(n)
	
