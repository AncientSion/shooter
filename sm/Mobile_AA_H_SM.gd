extends SM
class_name Mobile_AA_Heavy_SM

var check_move_target_frames:int = 30

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
			check_for_new_move_target()
			parent.process_movement(delta)
			var d = parent.global_position.distance_to(parent.curTarget.global_position)
			if d <= parent.sightRange:
				set_state(states.standoff)
			elif d >= parent.sightRange * 1.5:
				parent.remove_cur_target_set_new_target()
		states.standoff:
			check_for_new_move_target()
			var d = parent.global_position.distance_to(parent.moveTarget)
			if d >= parent.sightRange * 1.3:
				set_state(states.close)
		states.crash:
			parent.process_movement(delta)
			
func check_for_new_move_target():
	check_move_target_frames -= 1
	if check_move_target_frames > 0:
		return
	check_move_target_frames = 60
	if parent.curTarget.global_position > parent.global_position:
		parent.moveTarget = parent.curTarget.global_position + Vector2(200, 0)
	else:
		parent.moveTarget = parent.curTarget.global_position - Vector2(200, 0)
		
	parent.moveTarget.y = Globals.ROADY
	
func _get_transition(delta):
	pass
	
func _enter_state(prev_state, new_state):
	match state:
		states.idle:
			pass
		states.wander:
			parent.curTarget = null
			parent.setNewWanderTarget()
			parent.get_weapon_by_index(0).doDisable()
		states.close:
			parent.moveTarget = parent.curTarget.global_position
		states.standoff:
			parent.moveTarget = parent.curTarget.global_position
			parent.get_weapon_by_index(0).doEnable()
		states.crash:
			parent.setupCrashing()
		
	parent.moveTarget.y = Globals.ROADY
