extends SM
class_name Bomber_SM

var bombTimer:float = 2.0

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
			if parent.global_position.distance_to(parent.moveTarget) <= 100:
				parent.setNewWanderTarget()
		states.close:
			parent.process_movement(delta)
			var d = parent.global_position.distance_to(parent.moveTarget)
			if d <= 50:
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
			var distToTarget = parent.global_position.distance_to(parent.curTarget.global_position)
			var p = parent.curTarget.global_position.x - parent.global_position.x
			parent.moveTarget.x = parent.global_position.x + distToTarget * sign(p) + 1000 * sign(p)
			parent.moveTarget.y = parent.global_position.y - 50
			
			if parent.moveTarget.y <= parent.curTarget.global_position.y - 1000:
				parent.moveTarget.y = parent.curTarget.global_position.y - 600
		states.crash:
			parent.setupCrashing()
		
	if parent.moveTarget != Vector2.ZERO and state != states.crash:
		parent.moveTarget.x = clamp(parent.moveTarget.x, 400, Globals.WIDTH - 400)
		parent.moveTarget.y = clamp(parent.moveTarget.y, 400, Globals.HEIGHT - 400)
