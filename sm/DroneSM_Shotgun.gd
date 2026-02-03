extends SM
class_name Drone_Shotgun_SM

func _ready():
	add_state("wander")
	add_state("close")
	add_state("circle")
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
			var d = parent.global_position.distance_to(parent.moveTarget)
			if d <= 250:
				set_state(states.circle)
			elif d >= parent.sightRange * 1.35:
				parent.remove_cur_target_set_new_target()
				set_state(states.wander)
		states.circle:
			parent.process_movement(delta)
			if parent.global_position.distance_to(parent.moveTarget) <= 35:
				set_state(states.circle)
			elif parent.global_position.distance_to(parent.curTarget.global_position) < 100:
				set_state(states.circle)
			elif parent.global_position.distance_to(parent.curTarget.global_position) > 250:
				set_state(states.close)
		states.standoff:
			parent.moveTarget = parent.global_position - (parent.curTarget.global_position - parent.global_position).normalized() * 50
#			parent.moveTarget = parent.global_position
			parent.process_movement(delta)
			var d = parent.global_position.distance_to(parent.curTarget.global_position)
			if d >= parent.sightRange * 1.1:
				print("dist: ", d, ", > 1.1 x sightrange ", parent.sightRange, " - going CLOSEIN")
				set_state(states.close)
			elif d >= parent.sightRange * 1.35:
				parent.remove_cur_target_set_new_target()
				set_state(states.wander)
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
		states.circle:
#			var selfP = parent.global_position
#			var other = parent.curTarget.global_position
			var angleToTarget = rad2deg(parent.global_position.angle_to(parent.curTarget.global_position))
			var d = parent.global_position.distance_to(parent.curTarget.global_position)
			parent.moveTarget = parent.global_position + Vector2(d*0.7, 0).rotated(angleToTarget + Globals.getRandomEntry([5, 15]) * Globals.getRandomEntry([1, -1]))
#			parent.moveTarget = parent.curTarget.global_position + Vector2(Globals.getRandomEntry([50, 75]) * Globals.getRandomEntry([1, -1]), Globals.getRandomEntry([50, 75]) * Globals.getRandomEntry([1, -1]))
		states.standoff:
			parent.moveTarget = parent.curTarget.global_position
		states.crash:
			parent.setupCrashing()
