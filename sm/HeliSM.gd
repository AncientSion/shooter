extends SM
class_name Heli_SM

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
#				print("dist: ", d, ", below sightrange, ", parent.sightRange," - going STANDOFF")
				set_state(states.standoff)
			elif d >= parent.sightRange * 1.35:
				parent.remove_cur_target_set_new_target()
		states.standoff:
#			getPrefPosition()
#
			parent.moveTarget = parent.global_position - (parent.curTarget.global_position - parent.global_position).normalized() * 500
			parent.process_movement(delta)
			var d = parent.global_position.distance_to(parent.curTarget.global_position)
			if d >= parent.sightRange * 1.1:
#				print("dist: ", d, ", > 1.1 x sightrange ", parent.sightRange, " - going CLOSEIN")
				set_state(states.close)
			elif d >= parent.sightRange * 1.35:
				parent.remove_cur_target_set_new_target()
		states.crash:
			pass
#			parent.process_movement(delta)

func getPrefPosition():
		var selfToTarget:Vector2 = parent.global_position - parent.global_position
		var targetDirVec:Vector2 = selfToTarget
		var forwardVec = selfToTarget.dot(targetDirVec)
		var strafeVec:Vector2 = selfToTarget - forwardVec
	
func _get_transition(delta):
	pass
	
func _enter_state(prev_state, new_state):
			
	match state:
		states.idle:
			pass
		states.wander:
			if parent.curTarget == null and parent.targetsArr.size():
				parent.set_new_target()
			else:
				parent.setNewWanderTarget()
		states.close:
			if parent.curTarget == null and parent.targetsArr.size():
				parent.set_new_target()
		states.standoff:
			parent.moveTarget = parent.curTarget.global_position
		states.crash:
			parent.setupCrashing()
