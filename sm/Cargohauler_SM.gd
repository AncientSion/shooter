extends SM
class_name Cargohauler_SM

func _ready():
	add_state("wander")
	add_state("crash")
	add_state("idle")
	
	set_state(states.idle)

func _state_logic(delta):
	match state:
		states.idle:
			pass
		states.wander:
			parent.process_movement(delta)
			if parent.global_position.distance_to(parent.moveTarget) <= 75:
				parent.setNewWanderTarget()
		states.crash:
			parent.process_movement(delta)
	
func _get_transition(delta):
	pass
	
func _enter_state(prev_state, new_state):
	match state:
		states.idle:
			pass
		states.wander:
			parent.setNewWanderTarget()
		states.crash:
			parent.setupCrashing()
