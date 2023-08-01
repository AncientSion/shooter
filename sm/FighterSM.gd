extends SM
class_name FighterSM

func _ready():
	add_state("wander")
	add_state("close")
	add_state("trail")
	add_state("disengage")
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
			if parent.global_position.distance_to(parent.moveTarget) <= 100:
				if rand_range(0, 1) < 0.15:
					setMixUpWanderTarget()
				else:
					setNewWanderTarget()
#					print("ding")
		states.close:
			parent.moveTarget = parent.curTarget.global_position
			parent.processMovement(delta)
			var d = parent.global_position.distance_to(parent.curTarget.global_position)
#			print(rad2deg(parent.global_position.angle_to(parent.curTarget.global_position)))
			if d <= 250:
				set_state(states.disengage)
			elif d >= parent.sightRange * 1.5:
				parent.removeTarget()
				parent.setNewTarget()
				set_state(states.wander)
		states.disengage:
			parent.processMovement(delta)
			var d = parent.global_position.distance_to(parent.curTarget.global_position)
			if d >= 400:
				set_state(states.close)
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
			if rand_range(0, 1) > 0.5:
				parent.enableBoosting()
		states.disengage:
			var angle = Globals.rng.randi_range(15, 20) * Globals.getRandomEntry([1, -1])
			var variance = Vector2(1, 0).rotated(parent.global_rotation + deg2rad(angle)) * 600
			parent.moveTarget = parent.global_position + variance
			if rand_range(0, 1) > 0.5:
				parent.enableBoosting()
		states.oob:
			parent.moveTarget = Vector2(Globals.WIDTH/2, parent.global_position.y) 
			parent.enableBoosting()
		states.crash:
			parent.setupCrashing()
			
#	if parent.curTarget != null:
#		var d = parent.global_position.distance_to(parent.curTarget.global_position)
#		if d >= parent.sightRange * 1.2:
#			set_state(states.wander)
#			parent.targets.remove(parent.curTarget)
		
	if state != states.crash:
		parent.moveTarget.x = clamp(parent.moveTarget.x, 300, Globals.WIDTH - 300)
		parent.moveTarget.y = clamp(parent.moveTarget.y, 300, Globals.HEIGHT - 300)
	pass
	
func setMixUpWanderTarget():
	if parent.velocity.x > 0:
		parent.moveTarget.x = parent.global_position.x - 500
	elif parent.velocity.x < 0:
		parent.moveTarget.x = parent.global_position.x + 500
		

func setNewWanderTarget():
	var pos = parent.global_position
	var rot = parent.rotation_degrees
	var newTarget = Vector2.ZERO
	var limit = 400
	
	if parent.rotation_degrees > -90 and parent.rotation_degrees < 90:
		newTarget = pos + Vector2(400, Globals.getRandomEntry([1, -1]) * 20)
	else:
		newTarget = pos + Vector2(-400, Globals.getRandomEntry([1, -1]) * 20)
		
	if newTarget.x > Globals.WIDTH - limit:
		newTarget.x -= limit *4
	elif newTarget.x < 0 + limit:
		newTarget.x += limit *4
	
	if newTarget.y > Globals.HEIGHT:
		newTarget.y -= Globals.HEIGHT
	elif newTarget.y < 0:
		newTarget.y += Globals.HEIGHT
	
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
