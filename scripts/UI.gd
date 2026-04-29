extends CanvasLayer

onready var player = Globals.PLAYER
var ticks = 0
var shipstats:Node = null
var poi:Node = null

onready var missionUI = $Place/TopCenter/Mission_PC
onready var main_text = $Center/Difficulty_Text/Label
onready var text_tween = $Text_Tween
onready var pause = $Pause_details
onready var fps = $Place/TopleftRighter/Difficulty/Vbox/Fps/b

var counter:int = 0

func _ready():
	print("ui rdy")
	$ItemsPassive/VB.queue_free()
	$Toggle.connect("gui_input", self, "_on_Toggle_input_event")
	$Place/Topright/AI_PC.connect("gui_input", self, "_on_AI_PC_input_event")
	text_tween.connect("tween_all_completed", self, "empty_main_text")
	
	connect_difficulty_ui()
	init_poi_handler()
	add_player_debug_panel()
	addKeyForItem()
	
	reset_mission_sub_ui()
	
func _process(delta):
	fps.text = String(Engine.get_frames_per_second())
	
func init_poi_handler():
	poi = Globals.POI.instance()
	add_child(poi)

func reset_mission_sub_ui():
	missionUI.get_node("VBox/Type").hide()
	missionUI.get_node("VBox/Time").hide()
	missionUI.get_node("VBox/Progress").value = 0
	missionUI.get_node("VBox/Progress").hide()
	missionUI.get_node("VBox/mission_state_label/label").hide()
	missionUI.get_node("VBox/mission_state_label/label").text = ""
	missionUI.get_node("VBox/Targets_HP").hide()
	missionUI.get_node("VBox/Targets_HP/Template").hide()
	
	var targets_hp_nodes = $Place/TopCenter/Mission_PC/VBox/Targets_HP.get_children()
	if targets_hp_nodes.size() > 1:
		for n in range(1, targets_hp_nodes.size()):
			targets_hp_nodes[n].queue_free()
#	print("len: ", targets_hp_nodes.size())
		
	
func _on_Toggle_input_event(event):
	if  event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		var i = 0
		for n in get_children():
			if i > 2:
				n.visible = !n.visible
			i += 1
			
func _on_AI_PC_input_event(event):
	if  event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		$Place/Topright/AI_PC/VBoxC.visible = !$Place/Topright/AI_PC/VBoxC.visible
		
func reset_ui_ai_debug_list():
	var i = 0
	for n in $Place/Topright/AI_PC/VBoxC.get_children():
		if i > 0:
			n.queue_free()
		i+= 1
		
func init_pause_menu():
	$Pause_details.do_init()

func connect_difficulty_ui():
#signal diffi_updated
#signal wave_updated
#
#		player.connect("update_player_health", get_node("UI"), "_on_update_player_health")
#		player.connect("update_player_materials", get_node("UI"), "_on_update_player_materials")
	empty_main_text()
	Globals.handler_spawner.connect("wave_updated", self, "_on_wave_updated")
	Globals.handler_spawner.connect("diffi_updated", self, "_on_diffi_updated")
	
#	$Center/Difficulty_Text/Label
#	$Place/TopleftRighter/Difficulty/Vbox/Diff/b
#	$Place/TopleftRighter/Difficulty/Vbox/Wave/b

func _on_wave_updated(cur, max_str):
	$Place/TopleftRighter/Difficulty/Vbox/Wave/b.text = str(cur," / ",max_str)
	
func _on_diffi_updated(diffi):
	$Place/TopleftRighter/Difficulty/Vbox/Diff/b.text = str(diffi)
	set_main_text("Threat up")
	
	
func set_main_text(text):
	if text == "":
		empty_main_text()
		return
	
	counter +=1
	
#	print("set_main_text #", counter)
	$Center/Difficulty_Text.show()
	$Center/Difficulty_Text/Label.text = text
	text_tween.interpolate_property($Center/Difficulty_Text, "modulate:a",
			0, 1, 1,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	text_tween.interpolate_property($Center/Difficulty_Text, "rect_scale",
			Vector2(1, 1), Vector2(4, 4), 1.25,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	text_tween.start()
	
func empty_main_text():
#	return
	main_text.text = ""
	$Center/Difficulty_Text.hide()
	$Center/Difficulty_Text.modulate.a = 0.0
	$Center/Difficulty_Text.rect_scale = Vector2(1, 1)
	
func resetMissionUI():
	$Place/TopCenter/Mission_PC/VBox/Type.text = ""
	$Place/TopCenter/Mission_PC/VBox/Time/timeStr.text = ""
	$Place/TopCenter/Mission_PC/VBox/Progress.value = 0
	$Place/TopCenter/Mission_PC.show()
	$Place/TopCenter/Mission_PC/VBox/Time.show()
	$Place/TopCenter/Mission_PC/VBox/Progress.show()
	$Place/TopCenter/Mission_PC/VBox/HBox.hide()
	for n in $Place/TopCenter/Mission_PC/VBox/HBox.get_children():
		n.queue_free()
		
#	$Center/C.hide()

func _on_update_player_health(health, maxHealth):
#	print("_on_update_player_health ", Engine.get_idle_frames())
	shipstats.get_node("VBox/VBox_Traits/rowHealth/value").text = str(health)
#	shipstats.get_node("VBox/VBox_Traits/rowShield/value").text = str(shield)
	
#	$Bars/Panel/VBox/CC2/VBox/Shield.max_value = maxShield
	$Bars/Panel/VBox/CC_HealthShield/VBox/Bar_Health.max_value = maxHealth

#	if player.ticksShieldBreakTimer == 0:
#		$Bars/Panel/VBox/CC2/VBox/Shield.value = shield
#		$Bars/Panel/VBox/CC2/VBox/Shield/Value.text = str(shield, " / ", maxShield)
	$Bars/Panel/VBox/CC_HealthShield/VBox/Bar_Health.value = health
	$Bars/Panel/VBox/CC_HealthShield/VBox/Bar_Health/Value.text = str(health, " / ", maxHealth)
	
func _on_updateShield_UI_Nodes(shield, maxShield):
#	print("_on_updateShield_UI_Nodes")
	shipstats.get_node("VBox/VBox_Traits/rowShield/value").text = str(shield)
	$Bars/Panel/VBox/CC_HealthShield/VBox/Bar_Shield.value = shield
	$Bars/Panel/VBox/CC_HealthShield/VBox/Bar_Shield.max_value = maxShield
	$Bars/Panel/VBox/CC_HealthShield/VBox/Bar_Shield/Value.text = str(shield, " / ", maxShield)
	
func _on_updateShieldBreakCooldown(wait_time):
#	print("_on_updateShieldBreakCooldown")
	$Bars/Panel/VBox/CC_HealthShield/VBox/Bar_Shield/Value.text = str("%.1f" % wait_time)
	
func updateBoostChargeProps():
	$Bars/Panel/VBox/CC_Boost/Bar_Boost.max_value = player.boostMaxCharge
	$Bars/Panel/VBox/CC_Boost/Bar_Boost.value = player.boostCharge
	
	$Bars/Panel/VBox/CC_SideBoost/Bar_SideBoost.max_value = player.maxSideThrustDuration*100
	$Bars/Panel/VBox/CC_SideBoost/Bar_SideBoost.value = player.sideThrustDuration*100
	
func updateBoostChargeBar():
	$Bars/Panel/VBox/CC_Boost/Bar_Boost.value = player.boostCharge
	$Bars/Panel/VBox/CC_Boost/Bar_Boost/Value.text = str(round(player.boostCharge), " / ", player.boostMaxCharge)
	$Bars/Panel/VBox/CC_SideBoost/Bar_SideBoost.value = player.sideThrustDuration*100
	$Bars/Panel/VBox/CC_SideBoost/Bar_SideBoost/Value.text = str(("%.2f" % player.sideThrustDuration), " / ", ("%.2f" % player.maxSideThrustDuration))
	
func _on_update_player_materials(materials):
#	$Place/Bottomright/PlayerStats/VBox/VBox_Traits.get_child(3).get_node("value").text = str(materials)
	$Place/Bottomright/PlayerStats/VBox/VBox_Traits.get_node("rowMaterials").get_node("value").text = str(materials)

func add_player_debug_panel():
	shipstats = load("res://ui/PlayerStats.tscn").instance()
#	get_node("PlayerStatsPos").add_child(shipstats)
	
	$Place/Bottomright.add_child(shipstats)
	
	var keys = ["Health", "Materials", "Accel", "Velocity", "Boost", "BoostCharge", "Position", "Rotation", "ShiftCooldown", "ShiftDuration"]
	var values = ["maxHealth", "materials", "accel", "velocity", "boosting", "boostCharge", "position", "rotation_degrees", "shiftCooldown", "shiftDuration"]

	for n in len(keys):
		shipstats.addEntry(keys[n], player[values[n]])
		
	shipstats.addEntry("Dist", 0)
	shipstats.addEntry("Mouse", "")
	shipstats.addEntry("Grav", "")

func _input(_event):
#	print("input frame: ", Engine.get_idle_frames())
	if Input.is_action_pressed("wheel_up"):
#		print("wheel_up")
		player.selectWeapon(-1)
	elif Input.is_action_pressed("wheel_down"):
#		print("wheel_down")
		player.selectWeapon(1)
	elif _event.is_action_pressed("selectItem"):
		var index = (_event.scancode - 48)
		player.doSelectItem(index)
	
func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			Globals.toggle_pause_and_menu()
			
func addKeyForItem():
	if not InputMap.has_action("selectItem"):
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
	
func hideAIUI():
	$Place/Topright/AI_PC.hide()
	
func hideMissionUI():
	$Place/TopCenter/Mission_PC.hide()

func _on_ALL_value_changed(value):
	var val:float = value / 100
	get_node("Glow/MC/HA/VB/ALL").text = str(val)
	for n in Globals.curScene.get_node("Enemy_Units").get_child(0).get_node("Sprites").get_children():
		if n is AnimatedSprite:
			n.self_modulate = Color (val, val, val, 1)
			
	for n in get_node("Glow/MC/HA/VB").get_children():
		n.text = str(val)
	get_node("Glow/MC/HA/VA/R").value = value
	get_node("Glow/MC/HA/VA/G").value = value
	get_node("Glow/MC/HA/VA/B").value = value
		
func _on_R_value_changed(value):
	var val:float = value / 100
	get_node("Glow/MC/HA/VB/R").text = str(val)
	for n in Globals.curScene.get_node("Enemy_Units").get_child(0).get_node("Sprites").get_children():
		if n is AnimatedSprite:
			n.self_modulate.r = val

func _on_G_value_changed(value):
	var val:float = value / 100
	get_node("Glow/MC/HA/VB/G").text = str(val)
	for n in Globals.curScene.get_node("Enemy_Units").get_child(0).get_node("Sprites").get_children():
		if n is AnimatedSprite:
			n.self_modulate.g = val

func _on_B_value_changed(value):
	var val:float = value / 100
	get_node("Glow/MC/HA/VB/B").text = str(val)
	for n in Globals.curScene.get_node("Enemy_Units").get_child(0).get_node("Sprites").get_children():
		if n is AnimatedSprite:
			n.self_modulate.b = val
	
func update_on_start_mission(mission_class):
	print("update_on_start_mission")
	missionUI.get_node("VBox/mission_state_label/label").text = "ongoing"
	missionUI.get_node("VBox/mission_state_label/label").hide()
	missionUI.get_node("VBox/Type").text = mission_class.title
	missionUI.get_node("VBox/Type").show()
	missionUI.get_node("VBox/Time").show()
	missionUI.get_node("VBox/Progress").show()
	
	if missionUI.get_node("VBox/Targets_HP").get_children().size() > 1:
		missionUI.get_node("VBox/Targets_HP").show()
	
func update_on_success_mission(mission_class):
	print("update_on_success_mission")
	missionUI.get_node("VBox/Time").hide()
	missionUI.get_node("VBox/mission_state_label/label").text = "Mission Completed !"
	missionUI.get_node("VBox/mission_state_label/label").show()
	
func update_on_fail_mission(mission_class):
	print("update_on_fail_mission")
	missionUI.get_node("VBox/Time").hide()
	missionUI.get_node("VBox/mission_state_label/label").text = "Mission Failed !"
	missionUI.get_node("VBox/mission_state_label/label").show()
		
func add_target_healthbar_to_mission_bar(target):
	var vbox = VBoxContainer.new()
	vbox.set_h_size_flags(3)
	vbox.name = str("Progress_Mission_Unit_", missionUI.get_node("VBox/Targets_HP").get_children().size())
	var panel = PanelContainer.new()
	panel.theme_type_variation = "panel_noBorder"
	var label = Label.new()
	label.text = target.display
	label.align = VALIGN_CENTER
	var hpbar = ProgressBar.new()
	hpbar.theme_type_variation = "progress_health"
	hpbar.min_value = 0
	hpbar.max_value = round(target.maxHealth)
	hpbar.value = round(target.health)
	target.missionhealthbar = hpbar
	
	vbox.add_child(panel)
	panel.add_child(label)
	vbox.add_child(hpbar)
	
	missionUI.get_node("VBox/Targets_HP").add_child(vbox)

