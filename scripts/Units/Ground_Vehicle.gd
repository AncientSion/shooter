extends Ground_Entity
class_name Ground_Vehicle
	
	
func _ready():
#	print("texDim ", self.display, ": ", texDim)
	pass
	
func process_movement(_delta):
	set_interest()
	set_danger()
	choose_direction()
	accel = chosen_dir * maxSpeed
	accel = accel.limit_length(maxSpeed)
	velocity += accel * _delta
	velocity = velocity.limit_length(maxSpeed)
	if velocity.length() < minSpeed:
		velocity = velocity.normalized() * minSpeed
	
func setUnitFacing():
	if velocity.x < 0 and sprite.flip_h == false:
		doTurnaround()
	elif velocity.x >= 0 and sprite.flip_h == true:
		doTurnaround()
	
func applyForce(force):
	force.y = 0
	.applyForce(force)
	
func checkMoveTargetWithinBoundary():
	if $SM.state != $SM.states.crash:
		moveTarget.x = clamp(moveTarget.x, 300, Globals.WIDTH - 300)
		moveTarget.y = clamp(moveTarget.y, 300, Globals.ROADY)
	pass
	
func initAvoidValues():
	avoidValues = {"Player": 5.0, "Boundary": 5.0, "Obstacle": 5.0, "Jeep": 2.0, "City": 2.0}
	
func setNewWanderTarget():
	var pos:Vector2 = global_position
	var newTarget:Vector2 = Vector2(0, Globals.ROADY)
	var limit = sightRange + 1
	
	if direction.x > 0:
		newTarget.x += 400
	else:
		newTarget.x -= 400
		
	moveTarget = newTarget
	
#	if get_node("Sprites/Main").flip_h == false:
#		newTarget = pos + Vector2(400, 0)
#		if newTarget.x > Globals.WIDTH - limit:
#			newTarget.x -= 600
#	else:
#		newTarget = pos + Vector2(-400, 0)
#		if newTarget.x < 0 + limit:
#			newTarget.x += 600
#
#	moveTarget = newTarget
#	moveTarget.y = Globals.ROADY
	
func setupCrashing():
	$SM.canChangeState = false
	var scale = 0.4
	add_fire_smoke_fx(scale, 0.0)
	
	for n in (max_smoke * 2):
		var explo = Globals.getExplo("wreck", get_dmg_gfx_scale())
		explo.set_as_toplevel(true)
		explo.offset = get_point_inside_tex()
		explo.delay = 1 + rand_range(0.6, 1) * n
#		print("delay: ", explo.delay)
		$EffectNodes.add_child(explo)
	
	$Tween.interpolate_property(self, "maxSpeed", maxSpeed, 0, 3.0)
	$Tween.start()
	get_tree().create_timer(5.0).connect("timeout", self, "kill")
