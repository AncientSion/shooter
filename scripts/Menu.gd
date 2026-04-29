extends Node

#var stage0 = preload("res://scenes/Stage_0.tscn")
#var intermission = preload("res://scenes/Intermission.tscn")
#var map = preload("res://scenes/Map.tscn")

func _ready():
	Globals.MAIN_MENU = self
	fill_mission_pulldown()
	
func fill_mission_pulldown():
	var missions = Globals.handler_mission.get_mission_dict()
	for n in missions:
		$MC/PC/VBC/HBoxContainer/OptionButton.add_item(n)
	
func _on_Start_pressed():
	var selection = $MC/PC/VBC/HBoxContainer/OptionButton.get_item_text($MC/PC/VBC/HBoxContainer/OptionButton.get_selected_id())
	Globals.GAMESCREEN.start_new_mission_by_name(selection)

func _on_Intermission_pressed():
	var scene = load("res://scenes/Intermission.tscn")
#	var scene = intermission.instance()
	Globals.curScene = scene
	get_tree().get_root().add_child(scene)
	get_tree().set_current_scene(scene)
	queue_free()

func _on_Map_pressed():
	var scene = load("res://scenes/Map.tscn")
#	var scene = map.instance()
	Globals.MAP_SCENE = scene
	get_tree().get_root().add_child(scene)
	get_tree().set_current_scene(scene)
	queue_free()

func _on_Quit_pressed():
	get_tree().quit()

func _on_Real_pressed():
	Globals.GAMESCREEN.start_new_game()
