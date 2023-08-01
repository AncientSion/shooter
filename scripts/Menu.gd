extends Node

var stage0 = preload("res://scenes/Stage_0.tscn")
var intermission = preload("res://scenes/Intermission.tscn")

# Handle "Quit" button press
func _on_Button_Quit_pressed():
	get_tree().quit()

# Handle "Start" button press
func _on_Button_Start_pressed():
	Globals.curScene = stage0.instance()
	get_tree().get_root().add_child(Globals.curScene)
	get_tree().set_current_scene(Globals.curScene)
	queue_free()

func _on_Button_Start2_pressed():
	Globals.curScene = intermission.instance()
	get_tree().get_root().add_child(Globals.curScene)
	get_tree().set_current_scene(Globals.curScene)
	queue_free()
