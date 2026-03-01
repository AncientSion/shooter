extends Node

#var stage0 = preload("res://scenes/Stage_0.tscn")
#var intermission = preload("res://scenes/Intermission.tscn")
#var map = preload("res://scenes/Map.tscn")

func _ready():
	Globals.MAIN_MENU = self
	pass
	
func _on_Start_pressed():
	var scene = load("res://scenes/Stage_0.tscn").instance()
#	var scene = stage0.instance()
	Globals.curScene = scene
	get_tree().get_root().add_child(scene)
	get_tree().set_current_scene(scene)
	queue_free()

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
#	Globals.GAMESCREEN.add_child(map.instance())
