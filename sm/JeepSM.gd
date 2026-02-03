extends SM
class_name Jeep_SM

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
#			var d = parent.global_position.distance_to(parent.curTarget.global_position)
			var d = abs(parent.curTarget.global_position.x  - parent.global_position.x)
			if d <= parent.sightRange * 0.7:
				set_state(states.standoff)
			elif d >= parent.sightRange * 1.35:
				parent.remove_cur_target_set_new_target()
		states.standoff:
#			parent.moveTarget = parent.curTarget.global_position
			parent.process_movement(delta)
#			var d = parent.global_position.distance_to(parent.moveTarget)
			var d = abs(parent.curTarget.global_position.x  - parent.global_position.x)
			if d >= parent.sightRange * 1.1:
				set_state(states.close)
			elif abs(parent.moveTarget.x  - parent.global_position.x) < 5:
				set_state(states.standoff)
		states.crash:
			parent.process_movement(delta)
	
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
			parent.moveTarget = parent.curTarget.global_position
		states.standoff:
			parent.moveTarget.x = parent.curTarget.global_position.x + Globals.rng.randi_range(20, 40) * Globals.getRandomEntry([-1, 1])
		states.crash:
			parent.setupCrashing()
