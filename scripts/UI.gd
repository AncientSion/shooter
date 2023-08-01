extends CanvasLayer

onready var player = Globals.PLAYER
var ticks = 0
var shipstats = null

onready var missionUI = $Place/TopCenter/Mission_PC

func _ready():
	print("ui rdy")
#	return
	#$Place/Topleft/WeaponStatsPos.get_child(0).queue_free()
	#PlayerStatsPos.get_child(0).queue_free()
#	$ItemStatsPos.get_child(0).queue_free()
#	$ItemsActivePos/ItemsActive/HB.get_child(0).queue_free()
	$ItemsPassive/VB.queue_free()
	$Toggle.connect("gui_input", self, "_on_Toggle_input_event")
	$Pause.connect("resolutionChange", Globals.curScene, "_on_resolutionChange")
	#$Bars.connect("mouse_entered", self, "_on_mouse_in")
	#$Toggle.connect("mouse_entered", self, "_on_mouse_in")
	
	readyShipStatsPanel()
	addKeyForItem()
	
func _on_Toggle_input_event(event):
	if  event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		var i = 0
		for n in get_children():
			if i > 2:
				n.visible = !n.visible
			i += 1
	
func resetMissionUI():
	$Place/TopCenter/Mission_PC/VBox/HBox/Time.set("custom_colors/font_color", Color(1, 1, 1, 1))
	$Place/TopCenter/Mission_PC/VBox/Type.text = ""
	$Place/TopCenter/Mission_PC/VBox/HBox/Time.text = ""
	$Place/TopCenter/Mission_PC/VBox/Progress.value = 0
	$Place/TopCenter/Mission_PC/.show()

func _on_updatePlayerHP(health, maxhealth, shield, maxshield):	
	shipstats.get_node("VBox/VBox_Traits/rowHealth/value").text = str(health)
	shipstats.get_node("VBox/VBox_Traits/rowShield/value").text = str(shield)
	
	$Bars/Panel/Shield.value = shield
	if (shield > 0):
		$Bars/Panel/Shield/Value.text = str(shield, " / ", maxshield)
	$Bars/Panel/Health.value = health
	$Bars/Panel/Health/Value.text = str(health, " / ", maxhealth)
	
func _update_shieldBreakCooldown(wait_time):
	$Bars/Panel/Shield/Value.text = str(wait_time)
	
func _on_updatePlayerRes(ressources):
	$Place/Bottomright/PlayerStats/VBox/VBox_Traits.get_child(3).get_node("value").text = str(ressources)

func readyShipStatsPanel():
	shipstats = load("res://ui/PlayerStats.tscn").instance()
#	get_node("PlayerStatsPos").add_child(shipstats)
	
	$Place/Bottomright.add_child(shipstats)
	
	var keys = ["Health", "Shield", "Res", "Accel", "Velocity", "Boost", "BoostCharge", "Position", "Rotation"]
	var values = ["maxHealth", "maxShield", "ressources", "accel", "velocity", "isBoosting", "boostCharge", "position", "rotation_degrees"]

	for n in len(keys):
		shipstats.addEntry(keys[n], player[values[n]])
		
	shipstats.addEntry("Dist", 0)
	shipstats.addEntry("Mouse", "")

func _input(_event):
	if Input.is_action_just_pressed("wheel_up"):
#		print("wheel_up")
		player.selectWeapon(-1)
	elif Input.is_action_just_pressed("wheel_down"):
#		print("wheel_down")
		player.selectWeapon(1)
	elif _event.is_action_pressed("selectItem"):
		var index = (_event.scancode - 49)
		player.doSelectItem(index)
	
func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			Globals.togglePause()
			
func addKeyForItem():
	InputMap.add_action("selectItem")
	
	var event = InputEventKey.new()
	event.scancode = 49
	InputMap.action_add_event("selectItem", event)
	event = InputEventKey.new()
	event.scancode = 50
	InputMap.action_add_event("selectItem", event)
	event = InputEventKey.new()
	event.scancode = 51
	InputMap.action_add_event("selectItem", event)

func showMissionUI():
	$Place/TopCenter/Mission_PC.show()
	
func showAIUI():
	$Place/Topright/AI_PC.show()
	
func hideMissionUI():
	$Place/TopCenter/Mission_PC.hide()
	
func hideAIUI():
	$Place/Topright/AI_PC.hide()
