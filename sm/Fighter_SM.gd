extends SM
class_name Fighter_SM

func _ready():
	add_state("wander")
	add_state("close")
	add_state("trail")
	add_state("disengage")
	add_state("withdraw")
	add_state("crash")
	add_state("idle")

func _state_logic(delta):
	match state:
		states.idle:
			pass
		states.wander:
			parent.process_movement(delta)
			if parent.global_position.distance_to(parent.moveTarget) <= 100:
				parent.setNewWanderTarget()
		states.close:
			parent.process_movement(delta)
			parent.moveTarget = parent.curTarget.global_position
			var d = parent.global_position.distance_to(parent.curTarget.global_position)
#			parent.moveTarget = parent.curTarget.getFuturePosition(d/parent.velocity.length())
#			print(rad2deg(parent.global_position.angle_to(parent.curTarget.global_position)))
			if d <= 300:
				set_state(states.disengage)
			elif d >= parent.sightRange * 2:
				parent.remove_cur_target_set_new_target()
		states.disengage:
			parent.process_movement(delta)
			var d = parent.global_position.distance_to(parent.curTarget.global_position)
			if d >= 600: 
				set_state(states.close)
		states.withdraw:
			parent.process_movement(delta)
			var d = parent.global_position.distance_to(parent.moveTarget)
			if d <= 100:
				set_state(states.close)
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
			if parent.curTarget == null and parent.targetsArr.size():
				parent.set_new_target()
			else:
				parent.setNewWanderTarget()
		states.close:
			if parent.curTarget == null and parent.targetsArr.size():
				parent.set_new_target()
		states.disengage:
			var angle = Globals.rng.randi_range(15, 23) * Globals.getRandomEntry([1, -1])
			var variance = Vector2(1, 0).rotated(parent.global_rotation + deg2rad(angle)) * 500
			parent.moveTarget = parent.global_position + variance
		states.withdraw:
			var angle = Globals.rng.randi_range(15, 23) * Globals.getRandomEntry([1, -1])
			var variance = Vector2(1, 0).rotated(parent.global_rotation + deg2rad(angle)) * 900
			parent.moveTarget = parent.global_position + variance
		states.crash:
			parent.setupCrashing()
