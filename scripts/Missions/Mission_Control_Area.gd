extends Mission_Base
class_name Mission_Hold_Area

var x:int
var y:int
var w:int
var h:int
var color = Color(1.0, 0.0, 0.0, 0.2)
var inArea:bool = false

func _ready():
	pass
	
func _physics_process(delta):
	pass
	
func set_base_props():
	code = "CONTROL_AREA"
	title = "Control Designated Area"
	difficulty = 0
	reward = 0
	desc = "Secure the fortified zone and eliminate all hostiles.\nHold position until reinforcements arrive."
	
	
func mission_final_setup_self():
#func setup_control_area_mission(time):
#	mission = mission_control_area.instance()
#	Globals.curScene.get_node("Various").add_child(mission)
	do_init(60)
	
	var w = 900 * 1.0
	var h = 600 * 1.0
#	mission.doInit(Globals.WIDTH/2 - w/2, Globals.HEIGHT/2 - h/2, w, h)
	do_setup(Globals.WIDTH/2, Globals.HEIGHT/2, w, h)
#	setupObjectiveTimer(time)
#	missionStart()
	#Globals.curScene.get_node("MissionTimer").paused = false


func do_init(time):
	type = "Control Area"
	handler_m.missiontext.text = "Control Area"
	Globals.add_poi_marker(self)
	flicker()
	time = 3.0
	maxTime = time
	timeRemain = time
	
func do_setup(centerX, centerY, init_w, init_h):
#	print(init_x, "/", init_y)
#	position = Vector2(init_x + init_w/2, init_y + init_h/2)
	position = Vector2(centerX, centerY)
	x = centerX
	y = centerY
	w = init_w
	h = init_h
	#var col = $CollisionShape2D
	
	#print(col.shape.extents)
	#print(col.position)	
	$Area.polygon[0] = Vector2(-w/2, -h/2)
	$Area.polygon[1] = Vector2(w/2, -h/2)
	$Area.polygon[2] = Vector2(w/2, h/2)
	$Area.polygon[3] = Vector2(-w/2, h/2)
	$Area2D/CollisionShape2D.position = Vector2(0, 0)
	$Area2D/CollisionShape2D.shape.extents = Vector2(w/2, h/2)

func do_process(_delta):
	if inArea:
		timeRemain = max(0.0, timeRemain - _delta)
	else:
		timeRemain = min(maxTime, timeRemain + _delta)
		
	timeRemain = max(0, timeRemain)
	timerPct = timeRemain / maxTime * 100 / 100
	
	handler_m.timerLabel.text = "%.2f" % timeRemain
	handler_m.bar.value = (1-timerPct)*100
	
	if timeRemain <= 0.0:
		do_complete_mission()

func flicker():
#	return
	if handler_m.missionState != 2:
		var tree = get_tree()
		var tween = get_tree().create_tween()
		tween.tween_property($Area, "color:a", 0.3, 1.0)
		tween.tween_property($Area, "color:a", 0.1, 0.2)
		tween.tween_callback(self, "flicker")
#		var tween = get_tree().create_tween()
#		tween.tween_property($Area, "color:a", 0.3, 1.0)
#		tween.tween_property($Area, "color:a", 0.1, 0.2)
#		tween.tween_callback(self, "flicker")
	
func do_complete_mission():
	handler_m.missionState = 2
	handler_m.missionUI.get_node("VBox/Time").hide()
	handler_m.missionUI.get_node("VBox/mission_state_label/label").text = "Mission Completed !"
	handler_m.missionUI.get_node("VBox/mission_state_label/label").show()
	$Area.hide()
	Globals.remove_poi_marker(self)
	
func __draw():
	draw_rect(Rect2(0-(w/2), 0-(h/2), w, h), Color(1, 0, 0, 0.2))

func _on_Area2D_area_entered(area):
	inArea = true
	$Area.color.r = 0
	$Area.color.g = 1
	
func _on_Area2D_area_exited(area):
	$Area.color.r = 1
	$Area.color.g = 0
	inArea = false
