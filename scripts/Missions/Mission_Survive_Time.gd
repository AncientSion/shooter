extends Mission_Base
class_name Mission_Survive_Time

func _ready():
	pass
	
func _physics_process(delta):
	pass
	
func set_base_props():
	code = "SURVIVE"
	title = "Survive Interception Attempt"
	difficulty = 0
	reward = 0
	desc = "Enemy forces are hunting you—defend your position until extraction.\n Stay alive at all costs."
	
func do_init(time):
	type = "Survive_Time"
	handler_m.missiontext.text = "Survive"
	time = 15.0
	maxTime = time
	timeRemain = time
	
func do_setup():
	pass

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
