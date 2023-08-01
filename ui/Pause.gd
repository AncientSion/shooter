extends Control

onready var player = Globals.PLAYER
onready var res = $MC/VBC/VBC/PC/CC/HBC/Resolution

signal resolutionChange

func _ready():
#	print("pause rdy")
	$MC/VBC/HBC.get_child(0).queue_free()
	hide()
	
	for i in ["2560 x 1440", "1920 x 1080", "1600 x 900", "1366 x 768"]:
		res.add_item(i)
	res.selected = 1


func createPlayerStatsPanel():
	var panel = load("res://ui/PanelItemStats.tscn").instance()
	panel.get_node("VBox/VBox_Traits/Hbox/key").size_flags_stretch_ratio = 2.5
	panel.name = "Stats"
	panel.get_child(0).rect_min_size.x = 230
	panel.get_node("VBox/MC_Title/Label").text = player.display
	panel.get_node("VBox/MC_Qual").hide()
	
	$MC/VBC/HBC.add_child(panel)
	$MC/VBC/HBC.move_child(panel, 0)

	var keys = ["Max Health", "Max Shield", "", "Healthregen per Warp", "Shieldbreak cooldown", "Shieldregen timer", "", "Enginepower", "Max Speed", "BoostCharge", "Angular Rotation", "", "Cash"]
	var values = ["maxHealth", "maxShield", "", "healthRegenTime", "shieldBreakTime", "shieldRegenTime", "", "enginePower", "maxSpeed", "boostCharge", "agility", "", "ressources"]

	for n in len(keys):
		panel.addEntry(keys[n], player.get(values[n]))

func _on_Unpause_pressed():
	$MC/VBC/HBC/Stats.queue_free()
	Globals.togglePause()

func _on_Quit_pressed():
	get_tree().quit()

func _on_PC_visibility_changed():
	if visible == true:
		createPlayerStatsPanel()
	else:
		$MC/VBC/HBC.get_child(0).queue_free()

func _on_Resolution_item_selected(index):
	match index:
		0:
			Globals.SCREEN = Vector2(2560, 1440)
		1:
			Globals.SCREEN = Vector2(1920, 1080)
		2:
			Globals.SCREEN = Vector2(1600, 900)
		3:
			Globals.SCREEN = Vector2(1366, 768)
			
	emit_signal("resolutionChange")
	
#	update_container()

func _on_Zoom_item_selected(index):
	
	var entries = [1.33, 1.0, 0.67]
	Globals.curScene.setZoom(Vector2(entries[index], entries[index]))
#	match index:
#		0:
#			Globals.ZOOM = Vector2(2560, 1440)
#		1:
#			Globals.ZOOM = Vector2(1920, 1080)
#		2:
#			Globals.ZOOM = Vector2(1280, 720)
