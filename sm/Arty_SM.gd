extends SM
class_name Arty_SM

func _ready():
	add_state("wander")
	add_state("close")
	add_state("crash")
	add_state("idle")

func _state_logic(delta):
	match state:
		states.idle:
			pass
		states.wander:
			parent.process_movement(delta)
			if parent.global_position.distance_to(parent.moveTarget) <= 50:
				set_state(states.wander)
		states.close:
			parent.process_movement(delta)
			var d = parent.global_position.distance_to(parent.curTarget.global_position)
			if d >= parent.sightRange * 1.35:
				parent.remove_cur_target_set_new_target()
				set_state(states.wander)
		states.crash:
			pass
#			parent.process_movement(delta)
	
func _get_transition(delta):
	pass
	
func _enter_state(prev_state, new_state):
	match state:
		states.idle:
			pass
		states.wander:
			parent.curTarget = null
			parent.setNewWanderTarget()
		states.close:
			parent.moveTarget = Vector2.ZERO
		states.crash:
			parent.setupCrashing()
