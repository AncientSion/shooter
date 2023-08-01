extends SM
class_name HeliSM

func _ready():
	add_state("wander")
	add_state("close")
	add_state("standoff")
	add_state("crash")
	add_state("oob")
	add_state("idle")
	
	call_deferred("set_state", states.wander)

func _state_logic(delta):
	match state:
		states.idle:
			pass
		states.wander:
			parent.processMovement(delta)
			if parent.global_position.distance_to(parent.moveTarget) <= 50:
				set_state(states.wander)
		states.close:
			parent.moveTarget = parent.curTarget.global_position
			parent.processMovement(delta)
			var d = parent.global_position.distance_to(parent.curTarget.global_position)
			if d <= parent.sightRange:
				set_state(states.standoff)
			elif d >= parent.sightRange * 1.35:
				parent.removeTarget()
				parent.setNewTarget()
				set_state(states.wander)
		states.standoff:
			parent.moveTarget = parent.curTarget.global_position
			parent.processMovement(delta)
			var d = parent.global_position.distance_to(parent.moveTarget)
			if d >= parent.sightRange * 1.1:
				set_state(states.close)
			elif d >= parent.sightRange * 1.35:
				parent.removeTarget()
				parent.setNewTarget()
				set_state(states.wander)
		states.oob:
			parent.processMovement(delta)
			var d = parent.global_position.distance_to(parent.moveTarget)
			if d <= 250:
				set_state(states.wander)
		states.crash:
			parent.processMovement(delta)
	
func _get_transition(delta):
	pass
		
func _exit_state(prev_state, new_state):
#	for n in states:
#		if states[n] == prev_state:
#			print("_exit_state: ", n)
#			break
	pass
	
func _enter_state(prev_state, new_state):
			
	match state:
		states.idle:
			pass
		states.wander:
			parent.curTarget = null
			setNewWanderTarget()
		states.close:
			parent.moveTarget = parent.curTarget.global_position
		states.standoff:
			parent.moveTarget = parent.curTarget.global_position
		states.oob:
			parent.setAvoidBoundaryMoveTarget()
		states.crash:
			parent.setupCrashing()
			
	if not states.crash:
		parent.moveTarget.x = clamp(parent.moveTarget.x, 300, Globals.WIDTH - 300)
		parent.moveTarget.y = clamp(parent.moveTarget.y, 300, Globals.HEIGHT - 300)
	pass
	
func setNewWanderTarget():
	var pos = parent.global_position
	var rot = parent.rotation_degrees
	var newTarget = Vector2.ZERO
	var limit = parent.look_ahead + 1
	
	if parent.get_node("Sprite").flip_h == false:
		newTarget = pos + Vector2(300, 70 * Globals.getRandomEntry([1, -1]))
		if newTarget.x > Globals.WIDTH - limit:
			newTarget.x -= 600
			
	else:
		newTarget = pos + Vector2(-300, 70 * Globals.getRandomEntry([1, -1]))
		if newTarget.x < 0 + limit:
			newTarget.x += 600
#
	if newTarget.y > Globals.HEIGHT:
		newTarget.y -= Globals.HEIGHT
	elif newTarget.y < 0:
		newTarget.y += Globals.HEIGHT
#
#	newTarget.x = clamp(newTarget.x, limit, Globals.WIDTH - limit)
#	newTarget.y = clamp(newTarget.y, 600, Globals.HEIGHT - 600)
#
#	print("my pos: ", parent.global_position)
#	print("movetarget: ", newTarget)
	parent.moveTarget = newTarget





func setupCrashingx():
	print("setupCrashing")
#	set_state(states.crash)
	var scale = 0.4
	var fire = Globals.getFireNode(scale)
	fire.position = parent.getPointInsideTex()
	var smoke = Globals.getSmokeNode(scale)
	smoke.position = parent.getPointInsideTex()
	parent.addEffectNode(fire)
	parent.addEffectNode(smoke)
	
	for n in 2:
		var explo = Globals.getExplo("wreck", 3)
		explo.set_as_toplevel(true)
		explo.delay = (n+n+1)*3
		parent.get_node("EffectNodes").add_child(explo)

#		explo.position = parent.global_position
#		Globals.curScene.get_node("Various").add_child(explo)
	
	if parent.rotation_degrees < 0:
		parent.rotation_degrees += 360
		
	var descent = round(rand_range(25, 40))
	parent.descentTarget = 0
	parent.descentMod = 1
	parent.descentSpeed = parent.speed * 1.15
	parent.speed *= 1.15

	if parent.rotation_degrees > 270 or parent.rotation_degrees < descent:
		parent.descentTarget = descent
		parent.descentMod = 1
	elif parent.rotation_degrees > 180 - descent:
		parent.descentTarget = 180 - descent
		parent.descentMod = -1
#	elif rotation_degrees > descent and rotation_degrees < 180 - descent:
#		#crash right down
#		descentMod = 0
	elif parent.rotation_degrees > descent and parent.rotation_degrees < 90:
		parent.descentTarget = descent
		parent.descentMod = -1
	elif parent.rotation_degrees > 90 and parent.rotation_degrees < 180 - descent:
		parent.descentTarget = descent
		parent.descentMod = 1
