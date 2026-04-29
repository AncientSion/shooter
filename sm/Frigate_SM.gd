extends SM
class_name Frigate_SM

func _ready():
	add_state("wander")
	add_state("close")
	add_state("standoff")
	add_state("reposition")
	add_state("prepareWarpOut")
	add_state("crash")
	add_state("idle")

func _state_logic(delta):
	match state:
		states.idle:
			pass
		states.wander:
			parent.process_movement(delta)
			if parent.global_position.distance_to(parent.moveTarget) <= 100:
				set_state(states.wander)
		states.close:
			parent.moveTarget = parent.curTarget.global_position
			parent.process_movement(delta)
			var d = parent.global_position.distance_to(parent.curTarget.global_position)
			if d <= parent.sightRange * 0.85 and rand_range(0, 1) > 0.5:
				set_state(states.standoff)
			elif d >= parent.sightRange * 1.35:
				parent.remove_cur_target_set_new_target()
		states.standoff:
			parent.moveTarget = parent.global_position - (parent.curTarget.global_position - parent.global_position).normalized()*300
			parent.process_movement(delta)
			var d = parent.global_position.distance_to(parent.curTarget.global_position)
			if d >= parent.sightRange * 0.9:
				set_state(states.close)
		states.reposition:
			parent.process_movement(delta)
			var d = parent.global_position.distance_to(parent.moveTarget)
			if d <= 50:
				set_state(states.close)
		states.prepareWarpOut:
			parent.moveTarget = parent.global_position - (parent.curTarget.global_position - parent.global_position).normalized()*300
			parent.process_movement(delta)
		states.crash:
			pass
#			parent.process_movement(delta)
	
func _get_transition(delta):
	pass
		
func _exit_state(prev_state, new_state):
	return
	
func _enter_state(prev_state, new_state):
#	print(self.parent.display, ": _enter_state ", new_state)
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
			if (parent.curTarget != null and parent.curTarget.velocity.length() == 0 and rand_range(0, 1) > 0.3) or rand_range(0, 1) > 0.7:
				set_state(states.reposition)
		states.reposition:
			var valid:bool = false
			var angleFromTarget = rad2deg(parent.global_position.angle_to_point(parent.curTarget.global_position))
			var dist = max(800, parent.global_position.distance_to(parent.curTarget.global_position))
			var target:Vector2 = Vector2.ZERO
			while not valid:
				var adjust = Globals.rng.randi_range(10, 14) * Globals.getRandomEntry([-1, 1])
				target = parent.curTarget.global_position + Vector2(1, 0).rotated(deg2rad(angleFromTarget + adjust)) * dist
				if target.y < Globals.HEIGHT - parent.look_ahead*1.1 or target.y > parent.look_ahead*1.1:
					valid = true
#				else:
#					valid = false
#			print(target)
			parent.moveTarget = target
		states.prepareWarpOut:
			parent.setup_delayed_warp_out(6.0)
		states.crash:
			parent.setupCrashing()
