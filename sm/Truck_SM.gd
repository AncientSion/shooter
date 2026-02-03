extends SM
class_name Truck

func _ready():
	add_state("wander")
	add_state("close")
	add_state("standoff")
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
			parent.moveTarget = parent.curTarget.global_position
			parent.process_movement(delta)
			var d = parent.global_position.distance_to(parent.curTarget.global_position)
			if d <= parent.sightRange:
				set_state(states.standoff)
			elif d >= parent.sightRange * 1.35:
				parent.remove_cur_target_set_new_target()
				set_state(states.wander)
		states.standoff:
			parent.moveTarget = parent.curTarget.global_position
			parent.process_movement(delta)
			var d = parent.global_position.distance_to(parent.moveTarget)
			if d >= parent.sightRange * 1.1:
				set_state(states.close)
			elif d >= parent.sightRange * 1.35:
				parent.remove_cur_target_set_new_target()
				set_state(states.wander)
		states.crash:
			parent.process_movement(delta)
	
func _get_transition(delta):
	pass
		
func _exit_state(prev_state, new_state):
	pass
	
func _enter_state(prev_state, new_state):
	match state:
		states.idle:
			pass
		states.wander:
			parent.curTarget = null
			parent.setNewWanderTarget()
		states.close:
			parent.moveTarget = parent.curTarget.global_position
		states.standoff:
			parent.moveTarget = parent.curTarget.global_position
		states.crash:
			parent.setupCrashing()
