extends Node2D
class_name Mission_Base

enum M_State {
	INACTIVE = 0,   # Mission not yet started
	ACTIVE = 1,     # Mission in progress
	SUCCESS = 2,   # Mission completed favorably
	FAIL = 3       # Mission failed
}

var type:String = "Mission_Base"
var targets = []
var mission
var timerPct = 100
var virtTimeLeft = 0
var virtFullTime = 0
var deltaSumSinceLast = 0
var timeSinceLast:float = 0.0
var missionState = M_State.INACTIVE

var timeRemain:float =  0.0
var maxTime:float = 0.0

var amount:int = 0
var remaining:int = 0

var handler_m:Node = null
var handler_s:Node = null

#var missionUI
#var missiontext
#var timerLabel 
#var bar

onready var missionUI = Globals.UI.get_node("Place/TopCenter/Mission_PC")
onready var bar = missionUI.get_node("VBox/Progress")
onready var timerLabel = missionUI.get_node("VBox/Time/timeStr")
	
func _ready():
	pass
	
func _physics_process(_delta):
	if missionState == M_State.ACTIVE:
		do_process(_delta)
		do_process_time(_delta)
		
func do_process(_delta):
	pass

func do_process_time(_delta):
	if timeRemain > 0.0:
		timeRemain = max(0, timeRemain - _delta)
		timerLabel.text = "%.2f" % timeRemain
		bar.value = (1.0 - (timeRemain / maxTime)) * 100.0
		if timeRemain <= 0.0:
			set_mission_condition_fullfilled()
	
func do_init(init_time):
	pass
	
func do_init_mission(handler_mi, handler_sp):
	handler_m = handler_mi
	handler_s = handler_sp

func get_class():
	return str("get_class: ", code)
	
var code: String
var title: String
var difficulty: int
var reward: int
var desc: String
var unit_data = []
	
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
	return
	print("code: ", code)
	print("title: ", title)
	print("difficulty: ", difficulty)
	print("reward: ", reward)
	print("desc: ", desc)
	for n in unit_data:
		print(n)
		
func do_start_mission():
	print("do_start_mission")
	missionState = M_State.ACTIVE
	Globals.UI.update_on_start_mission(self)

func set_mission_condition_fullfilled():
	print("set_mission_condition_fullfilled()")
	missionState = M_State.SUCCESS
	Globals.MAP_SCENE.selected_node.do_mark_mapnode_as_complete()
	Globals.UI.update_on_complete_mission(self)
#
	if Globals.PLAYER.is_connected("_has_warped_in", self, "do_start_mission"):
		Globals.PLAYER.disconnect("_has_warped_in", self, "do_start_mission")
