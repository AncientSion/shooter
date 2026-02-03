extends SM
class_name PlayerSM

func _ready():
	pass
#	add_state("control")
#	call_deferred("set_state", states.control)

func _process_state_logic(delta):
	_state_logic(delta)
	
func _get_transition(_delta):
	pass
		
func _exit_state(prev_state, new_state):
	pass
	
func _enter_state(prev_state, new_state):
	pass

func _state_logic(delta):
	parent.process_movement(delta)
