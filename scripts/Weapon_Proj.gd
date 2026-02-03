extends Weapon_Base
class_name Weapon_Proj

#func _physics_process(delta):
#	print("ding")

	
func get_class():
	return "Weapon_Proj"

func eject_shell_casing():
	
	var case_emitter = Globals.EMPTY_SHELL.instance()
	case_emitter.do_init(global_position, global_rotation)
	Globals.curScene.get_node("Fluff").add_child(case_emitter)
	
