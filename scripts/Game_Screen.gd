extends Node2D

var cur_lvl_number:int

#var stage0 = preload("res://scenes/Stage_0.tscn")
#var intermission = preload("res://scenes/Intermission.tscn")
#var map = preload("res://scenes/Map.tscn")

func _ready():
	Globals.GAMESCREEN = self
	$Menu_BG/Main_Menu/MC/PC/VBC/GFX_settings.init_resolution()
	Globals.set_resolution()

func start_new_game():
	init_handlers()
	init_ui()
	init_map_scene()
	
func start_new_game_without_map():
	init_handlers()
	init_ui()
	
	var node = Globals.MAP_NODE.instance()
	node.do_init(
		"test",
		"test",
		Vector2(0, 0),
		-1,
		0,
#		Globals.handler_mission.get_mission_by_name("mission_protect_cargo_hauler")
#		Globals.handler_mission.get_mission_by_name("mission_survive_time")
		Globals.handler_mission.get_mission_by_name("mission_raid_convoy_light")
	)
	
	start_new_mission(node)
	
func load_player_ui():
	Globals.UI = load("res://ui/UI.tscn").instance()
	$Menu_BG.add_child(Globals.UI)

func init_handlers():
	print("init_handlers")
	Globals.handler_mission.do_bare_setup()
	Globals.handler_spawner.do_bare_setup()
#	Globals.handler_spawner.do_disable()
#	Globals.handler_mission.set_obj()

func init_ui():
	print("init_ui")
	Globals.UI = load("res://ui/UI.tscn").instance()
	
func init_map_scene():
	print("init_map_scene")
	Globals.MAP_SCENE = load("res://scenes/Map.tscn").instance()
	$Menu_BG.add_child(Globals.MAP_SCENE)

func start_new_mission(mission_node:Map_Node):
	print("start_new_mission")
	
	if  mission_node:
		mission_node.mission_class.logic.print_props()
		Globals.handler_spawner.mission_unit_data =  mission_node.mission_class.logic.unit_data
		print("__________")
		print("do start mission")
		
		Globals.curScene = load("res://scenes/Stage_0.tscn").instance()
		Globals.curScene.name = "Level"
		Globals.curScene.get_node("Objective_Scene").add_child( mission_node.mission_class)
		Globals.curScene.add_child(Globals.UI)
		
		Globals.GAMESCREEN.add_child(Globals.curScene)
		Globals.GAMESCREEN.get_node("Menu_BG").hide()
		
		#Globals.handler_mission.connect_mission_ui_in_game()
		Globals.handler_mission.mission_node = mission_node
		Globals.handler_mission.do_enable()
		
		Globals.handler_spawner.increase_difficulty(15)
		
		Globals.handler_spawner.connect_debug_diffi_ui_in_game()
		Globals.handler_spawner.do_enable()
		
		mission_node.mission_class.logic.mission_final_setup_self()
		
#		Globals.handler_mission.do_start_mission()

func on_warp_out_end_level():
	print("on_warp_out_end_level")
	
#	for n in Globals.curScene.get_node("Enemy_Units").get_children():
##		if n.isTarget:
##			n.unmark_as_target()
#		n.queue_free()
#
#	for n in Globals.curScene.get_node("Neutral_Units").get_children():
##		if n.isTarget:
##			n.unmark_as_target()
#		n.queue_free()
	Globals.handler_mission.terminate_remains_on_mission_scene_end()
	Globals.PLAYER.on_exit_level()
	Globals.PLAYER.unload_gear()
	Globals.handler_spawner.do_disable()
	Globals.handler_mission.do_disable()
	
	call_deferred("return_to_map")
	
#	print("d")

func return_to_map():
	print("return to map")
	Globals.curScene.get_node("Player_Pos").remove_child(Globals.PLAYER)
	Globals.UI.get_node("Pause_details/MC/VBC/PC/HBC2/GFX_settings").disconnectResolutionChange()
	
	Globals.UI.reset_ui_ai_debug_list()
	Globals.curScene.remove_child(Globals.UI)
	Globals.curScene.queue_free()
	
	for n in Globals.UI.get_node("LootNodes").get_children():
		n.queue_free()
	for n in Globals.UI.get_node("POI/actives").get_children():
		n.queue_free()
		
	Globals.GAMESCREEN.get_node("Menu_BG").show()
	
	Globals.MAP_SCENE.do_progress()
	

func actually_change(): #dead
	Globals.PLAYER.on_exit_level()
	Globals.curScene.get_node("Player_Pos").remove_child(Globals.PLAYER)
	Globals.UI.get_node("Pause_details/MC/VBC/PC/HBC2/GFX_settings").disconnectResolutionChange()
	
	Globals.UI.reset_ui_ai_debug_list()
	Globals.curScene.remove_child(Globals.UI)
	Globals.curScene.queue_free()
	
	for n in Globals.UI.get_node("LootNodes").get_children():
		n.queue_free()
	for n in Globals.UI.get_node("POI/actives").get_children():
		n.queue_free()
		
	match cur_lvl_number:
		0:
			cur_lvl_number = 1
			Globals.curScene = Globals.STAGEZERO.instance()
		1:
			cur_lvl_number = 0
			Globals.curScene = Globals.INTERMISSION.instance()

	Globals.curScene.name = str("Level_", cur_lvl_number)
	Globals.curScene.add_child(Globals.UI)
	
	Globals.GAMESCREEN.add_child(Globals.curScene)
#	print("adding new scene")
#	get_tree().get_root().add_child(Globals.curScene)
#	print("set current scene")
#	get_tree().set_current_scene(Globals.curScene)

func actuallyChange(): #dead
		
	Globals.PLAYER.on_exit_level()
	Globals.curScene.get_node("Player_Pos").remove_child(Globals.PLAYER)
	Globals.UI.get_node("Pause_details/MC/VBC/PC/HBC2/GFX_settings").disconnectResolutionChange()
	Globals.curScene.remove_child(Globals.UI)
#	$UI/Pause_details/MC/VBC/PC/HBC2/GFX_settings.disconnectResolutionChange()
	Globals.curScene.queue_free()
	
	for n in Globals.UI.get_node("LootNodes").get_children():
		n.queue_free()
	for n in Globals.UI.get_node("POI").get_children():
		n.queue_free()
	var i = 0
	for n in Globals.UI.get_node("Place/Topright/AI_PC/VBoxC").get_children():
		if i > 0:
			n.queue_free()
		i+= 1
		
	match cur_lvl_number:
		0:
			cur_lvl_number = 1
			Globals.curScene = Globals.STAGEZERO.instance()
		1:
			cur_lvl_number = 0
			Globals.curScene = Globals.INTERMISSION.instance()

	Globals.curScene.add_child(Globals.UI)
	
	
#	print("adding new scene")
	get_tree().get_root().add_child(Globals.curScene)
#	print("set current scene")
	get_tree().set_current_scene(Globals.curScene)
	
