extends Control

onready var player = Globals.PLAYER

func _ready():
	pass

func do_init():
	$MC/VBC/HBC.get_child(0).queue_free()
	$MC/VBC/PC/HBC2/GFX_settings.init_resolution()
	hide()

func createPlayerStatsPanel():
	var panel = load("res://ui/PanelItemStats.tscn").instance()
	panel.get_node("VBox/VBox_Traits/Hbox/key").size_flags_stretch_ratio = 2.5
	panel.name = "Stats"
	panel.get_child(0).rect_min_size.x = 230
	panel.get_node("VBox/MC_Title/Label").text = player.display
	panel.get_node("VBox/MC_Qual").hide()
	
	$MC/VBC/HBC.add_child(panel)
	$MC/VBC/HBC.move_child(panel, 0)

#	var keys = ["Max Health", "Max Shield", "", "Healthregen per Warp", "Shieldbreak cooldown", "Shieldregen timer", "", "Enginepower", "Max Speed", stCharge", "Angular Rotation", "", "Cash"]
#	var values = ["maxHealth", "maxShield", "", "healthRegenTime", "shieldBreakTime", "shieldRegenTime", "", "enginePower", "maxSpeed", "boostCharge", "agility", "", "resources"]

	var keys = ["Max Health", "Max Shield", "", "Hullrepair / Warp", "Shieldbreak cooldown", "Shieldregen timer", "", "Enginepower", "boostMaxCharge", "Boostpower", "Angular Rotation", "", "Materials"]
	var values = ["maxHealth", "maxShield", "", "healthRegenTime", "shieldBreakTime", "shieldRegenTime", "", "enginePower", "boostMaxCharge", "boostPower", "agility", "", "materials"]

	for n in len(keys):
#		panel.addEntry(keys[n], player.get(values[n]))
		panel.addEntry(keys[n], player.getStatByName(values[n]))

func _on_Unpause_pressed():
	$MC/VBC/HBC/Stats.queue_free()
	Globals.toggle_pause_and_menu()

func _on_Quit_pressed():
	get_tree().quit()

func _on_PC_visibility_changed():
	if visible == true:
		createPlayerStatsPanel()
	else:
		$MC/VBC/HBC.get_child(0).queue_free()
