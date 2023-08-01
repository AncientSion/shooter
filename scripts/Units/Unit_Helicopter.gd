extends Air_Unit
class_name Helicopter_Light

var display = "Helicopter_Light"

func doInit():
	.doInit()
	
func setStats():
#	maxHealth = 43
#	armor = 1
#	speed = 120
##	maxSpeed = 500
#	lootValue = 6
#	sightRange = 700
#	look_ahead = 600
	
	
	maxHealth = stats.health
	armor = stats.armor
	speed = stats.speed
	speed = 0
	minSpeed = stats.minSpeed
	lootValue = stats.lootValue
	sightRange = stats.sightRange
	look_ahead = stats.look_ahead
	

func _physics_process(_delta):
	pass
	
func processMovement(_delta):
	if destroyed or moveTarget == null or $SM.state == $SM.states.crash:
		return
		
	set_interest()
	set_danger()
	choose_direction()
	accel = chosen_dir.rotated(rotation) * speed
	accel = accel.limit_length(maxSpeed)
	velocity += accel * _delta
	velocity = velocity.limit_length(maxSpeed)
	
	position += extForces * _delta
	position += velocity * _delta

	setSpriteFacing()
	
func checkOOB():
	if state_m.state != state_m.states.oob and state_m.state != state_m.states.crash:
		var futurePos = global_position + (velocity)*2
		if futurePos.x < 100 or futurePos.x > Globals.WIDTH - 100 or futurePos.y < 300 or futurePos.y > Globals.HEIGHT - 300:
			$SM.set_state($SM.states.oob)

func setSpriteFacing():
	if curTarget == null:
		if moveTarget.x - position.x < 0:
			if $Sprite.flip_h == false:
				doTurnaround()
		else:
			if $Sprite.flip_h == true:
				doTurnaround()
	else: doFaceTarget()

func doFaceTarget():
	if curTarget.global_position.x - position.x < 0:
		if $Sprite.flip_h == false:
			doTurnaround()
	else:
		if $Sprite.flip_h == true:
			doTurnaround()

func doTurnaround():
	$Sprite.flip_h = !$Sprite.flip_h
	mirrorTurrets()
	mirrorThrusters()
	mirrorVarious()
	mirrorColNodes()
	mirrorSprite()

func mirrorSprite():
	if $Sprite.flip_h == true:
		$Sprite.rotation = -(2*rotation)
	else: $Sprite.rotation = 0
	
func getBehaviorVector():
	match state_m.state:
		state_m.states.wander: return seekVector()
		state_m.states.close: return seekVector()
		state_m.states.standoff: return -seekVector()
		state_m.states.oob: return seekVector()
		state_m.states.crash: return crashVector()
	return Vector2.ZERO
		
func seekVector():
	var vector_to_target = (moveTarget - global_position).normalized() * speed
	return vector_to_target
	
func crashVector():
	rotation_degrees += 5 * descentMod
	if descentMod == 1:
		rotation_degrees = max(rotation_degrees + 360, descentTarget + 360)
	else: 
		rotation_degrees = min(rotation_degrees + 360 , descentTarget + 360)
	var dir = Vector2(1, 0).rotated(rotation) * descentSpeed
	return dir

func getPossibleWeapons(index):
	return
#	var weapon = Globals.getSpecificBaseWeaponByName("Beamlance");
#	var weapon = Globals.getSpecificBaseWeaponByName("Heavy Machinecannon");
	var weapon = Globals.getSpecificBaseWeaponByName("Light Railgun");
#	weapon.makeUntargetable()
	return weapon

func setAvoidBoundaryMoveTarget():
	if global_position.x < 200:
		moveTarget = global_position + Vector2(300, 0)
	elif global_position.x > Globals.WIDTH - 200:
		moveTarget = global_position + Vector2(-300, 0)
	if global_position.y < 300:
		moveTarget = global_position + Vector2(0, 300)
	elif global_position.y > Globals.HEIGHT - 300:
		moveTarget = global_position + Vector2(0, -300)
	
func getDangerValueFromEntity(display):
	match display:
		"Player":
			return 5.0
		"Fighter":
			return 2.0
		"Helicopter_Light":
			return 2.0
		"Boundary":
			return 15.0
		"Obstacle":
			return 15.0


func crashIsTriggered(remDmg):
	return false
	return $SM.state != $SM.states.crash
#	return true
	
func setupCrashing():
	var scale = 0.5
	
	for n in 2:
		var fire = Globals.getFireNode(scale)
		fire.position = getPointInsideTex()
		var smoke = Globals.getSmokeNode(scale)
		smoke.position = getPointInsideTex()
		addEffectNode(fire)
		addEffectNode(smoke)
	
	for n in 4:
		var explo = Globals.getExplo("wreck", 3)
		explo.set_as_toplevel(true)
		explo.delay = (n+n+1)*3
		get_node("EffectNodes").add_child(explo)

	var direction:int = 1
	if $Sprite.flip_h == true:
		direction = -1
	
	var rota = round(rand_range(15, 25)) * direction
	var speed = 70
	var time = (Globals.HEIGHT - global_position.y) / speed
	var targetX = 550 * direction
	
	$Tween.interpolate_property(self, "position",
		global_position, global_position + Vector2(targetX, Globals.HEIGHT), ceil(time),
		Tween.TRANS_QUAD, Tween.EASE_IN)
		
	$Tween.interpolate_property(self, "rotation_degrees",
		rotation_degrees, rotation_degrees + rota, ceil(time* 0.9),
		Tween.TRANS_QUAD, Tween.EASE_IN)
		
	$Tween.start()
	yield($Tween, "tween_all_completed")
