extends Mission_Base
class_name Mission_Hold_Area

var x:int
var y:int
var w:int
var h:int
var color = Color(1.0, 0.0, 0.0, 0.2)
var inArea:bool = false
var poi_dummy:Currency = null

onready var zone_polygon:Polygon2D = owner.get_node("Area")
onready var zone_area:Area2D = owner.get_node("Area2D")

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
	do_init(60)
	
	var w = 900 * 1.0
	var h = 600 * 1.0
	do_setup(Globals.WIDTH/2, Globals.HEIGHT/2, w, h)
	create_poi()

func do_init(init_time):
	flicker()
	maxTime = init_time
	timeRemain = init_time
	
func do_setup(centerX, centerY, init_w, init_h):
	x = centerX
	y = centerY
	w = init_w
	h = init_h
	
	zone_polygon.position = Vector2(centerX, centerY)
	var points = [Vector2(-w/2, -h/2), Vector2(w/2, -h/2), Vector2(w/2, h/2), Vector2(-w/2, h/2)]
	var poly = PoolVector2Array()
	for n in points:
		poly.append(n)
	zone_polygon.polygon = poly

#	zone_polygon.polygon[0] = Vector2(-w/2, -h/2)
#	zone_polygon.polygon[1] = Vector2(w/2, -h/2)
#	zone_polygon.polygon[2] = Vector2(w/2, h/2)
#	zone_polygon.polygon[3] = Vector2(-w/2, h/2)

	zone_area.position = Vector2(centerX, centerY)
	zone_area.monitoring = true
	zone_area.get_node("CollisionShape2D").disabled = false
	zone_area.get_node("CollisionShape2D").position = Vector2(0, 0)
	zone_area.get_node("CollisionShape2D").shape.extents = Vector2(w/2, h/2)
	
	create_poi_dummy_unit(Vector2(centerX, centerY))
	
func create_poi():
	Globals.add_poi_marker(poi_dummy)
	
func create_poi_dummy_unit(pos):
	var reward = Globals.CURRENCY.instance()
	Globals.curScene.get_node("Various").add_child(reward)
#	reward.hide()
	reward.set_physics_process(false)
	reward.get_node("ColNodes").monitoring = false
	poi_dummy = reward
#	Globals.curScene.get_node("Various").add_child(reward)
	reward.position = global_position + pos

func do_process(_delta):
	if inArea:
		timeRemain = max(0.0, timeRemain - _delta)
	else:
		timeRemain = min(maxTime, timeRemain + _delta)
		
	timeRemain = max(0, timeRemain)
	timerPct = timeRemain / maxTime * 100 / 100
	
	timerLabel.text = "%.2f" % timeRemain
	bar.value = (1-timerPct)*100
	
	if timeRemain <= 0.0:
		set_mission_condition_fullfilled()

func player_toggle_area_control():
	inArea = !inArea
	
	if inArea:
		zone_polygon.color.g = 1
		zone_polygon.color.r = 0
	else:
		zone_polygon.color.r = 1
		zone_polygon.color.g = 0

func flicker():
	if missionState == M_State.ACTIVE:
		var tree = get_tree()
		var tween = get_tree().create_tween()
		tween.tween_property(zone_polygon, "color:a", 0.3, 1.0)
		tween.tween_property(zone_polygon, "color:a", 0.1, 0.2)
		tween.tween_callback(self, "flicker")
	
func set_mission_condition_fullfilled():
	.set_mission_condition_fullfilled()
	if has_node("Area"):
		zone_polygon.hide()
	if Target_Indicator != null:
		Globals.remove_poi_marker(self)

