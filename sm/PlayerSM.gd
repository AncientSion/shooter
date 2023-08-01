extends SM
class_name PlayerSM

func _ready():
	add_state("control")
	call_deferred("set_state", states.control)

#func _physics_process(delta):
#	if state != null:
#		_state_logic(delta)
#		var transition = _get_transition(delta)
#		if transition != null:
#			set_state(transition)
	
#func set_state(new_state):
#	pass
		
#func add_state(state_name):
#	pass
	
func _get_transition(delta):
	pass
		
func _exit_state(prev_state, new_state):
	pass
	
func _enter_state(prev_state, new_state):
	pass

func _state_logic(delta):
	parent.processMovement(delta)
