extends SM
class_name Drone_Kamikaze_SM

func _ready():
	add_state("wander")
	add_state("close")
	add_state("circle")
	add_state("prepStrike")
	add_state("strike")
	add_state("crash")
	add_state("idle")

func _state_logic(delta):
	match state:
		states.idle:
			parent.setSelfFacing(delta)
			pass
		states.wander:
			parent.process_movement(delta)
			if parent.global_position.distance_to(parent.moveTarget) <= 50:
				set_state(states.wander)
		states.close:
			parent.moveTarget = parent.curTarget.global_position
			parent.process_movement(delta)
			var d = parent.global_position.distance_to(parent.moveTarget)
			if d <= 500:
				set_state(states.circle)
			elif d >= parent.sightRange * 1.35:
				parent.remove_cur_target_set_new_target()
				set_state(states.wander)
		states.circle:
			parent.process_movement(delta)
			if parent.global_position.distance_to(parent.moveTarget) <= 50:
				if rand_range(0, 1) > 0.07:
					set_state(states.prepStrike)
				else:
					set_state(states.circle)
			elif parent.global_position.distance_to(parent.curTarget.global_position) > 700:
				set_state(states.close)
		states.prepStrike:
			parent.process_movement(delta)
			if parent.global_position.distance_to(parent.curTarget.global_position) > 700:
				set_state(states.close)
			else:
				parent.doPowerDown()
				set_state(states.idle)
#			elif parent.global_position.distance_to(parent.moveTarget) <= 30:
#				if parent.velocity.length() <= 60:
#					set_state(states.strike)
		states.strike:
			parent.moveTarget = parent.curTarget.global_position
			parent.process_movement(delta)
		states.crash:
			parent.process_movement(delta)
	
func _get_transition(delta):
	pass	
		
func _exit_state(prev_state, new_state):
	match prev_state:
		states.strike:
			parent.selfDestruct()
	
func _enter_state(prev_state, new_state):
#	print("#", parent.id, " enter state: ", new_state)
	match state:
		states.idle:
			pass
		states.wander:
			parent.curTarget = null
			parent.setNewWanderTarget()
		states.close:
			parent.moveTarget = parent.curTarget.global_position
		states.circle:
			var angleToTarget = rad2deg(parent.global_position.angle_to_point(parent.curTarget.global_position))
			var d = parent.global_position.distance_to(parent.curTarget.global_position)
			var dir = 1
			if rand_range(0, 1) > 0.7:
				dir = -1
			parent.moveTarget = parent.curTarget.global_position + Vector2(400, 0).rotated(deg2rad(angleToTarget + 35 * dir))
		states.prepStrike:
			parent.moveTarget = parent.global_position - parent.velocity
		states.strike:
			parent.enableBoosting()
			canChangeState = false
		states.crash:
			parent.setupCrashing()
#		states.selfd:
#			parent.selfDestruct()
