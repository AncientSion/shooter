extends Air_Unit
class_name Fighter

var display = "Fighter"

export var steer_force:int = 30
var boosting = false
var boostTimeRemain:float = 2.0
	
func setStats():
#	maxHealth = 16
#	armor = 0
#	speed = Globals.rng.randi_range(180, 200)
#	minSpeed = floor(speed * 0.85)
#	lootValue = 3
#	sightRange = 600
#	look_ahead = 300
	
	maxHealth = stats.health
	armor = stats.armor
	speed = stats.speed
	minSpeed = stats.minSpeed
	lootValue = stats.lootValue
	sightRange = stats.sightRange
	look_ahead = stats.look_ahead
	
func doInit():
	.doInit()
	var facing = Globals.rng.randi_range(-8, 8)
	if position.x > Globals.WIDTH / 2:
		facing += 180
	velocity = Vector2(1, 0).rotated(deg2rad(facing))
	rotation = velocity.angle()

func _physics_process(_delta):
	pass
	
func setDirection(_dirVector = false):
	pass
	
func processMovement(_delta):
	if destroyed or moveTarget == null:
		return
			
	set_interest()
	set_danger()
	choose_direction()
	accel += chosen_dir.rotated(rotation) * speed
	accel = accel.limit_length(maxSpeed + steer_force)
	velocity += accel * _delta
	velocity = velocity.limit_length(maxSpeed)
	if velocity.length() < minSpeed:
		velocity = velocity.normalized() * minSpeed

	rotation = velocity.angle()

	extForces += gravity_vec
	
	position += extForces * _delta
	position += velocity * _delta

	if boosting:
		boostTimeRemain -= _delta
		if boostTimeRemain <= 0:
			disableBoosting()
			
	setSpriteFacing()
	
func set_danger():
	if $SM.state != $SM.states.crash:
		.set_danger()
	
func processMovemenxxt(_delta):
	if destroyed or moveTarget == null:
		return
	
	var steer = getBehaviorVector()
	accel += steer
#	if accel > accel.limit_length(speed):
	accel = accel.limit_length(speed)
	velocity += accel * _delta
	velocity = velocity.limit_length(speed)
	if velocity.length() < minSpeed:
		velocity = velocity.normalized() * minSpeed
	rotation = velocity.angle()

	extForces += gravity_vec
	position += extForces * _delta
	position += velocity * _delta
	
	if boosting:
		boostTimeRemain -= _delta
		if boostTimeRemain <= 0:
			disableBoosting()
	checkOOB()
	
func setSpriteFacing():
	if velocity.x < 0:
		sprite.flip_v = true
	else:
		sprite.flip_v = false
		
func checkOOB():
	if state_m.state != state_m.states.oob and state_m.state != state_m.states.crash:
		var futurePos = global_position + (velocity)*2
		if futurePos.x < 100 or futurePos.x > Globals.WIDTH - 100 or futurePos.y < 150 or futurePos.y > Globals.HEIGHT - 150:
			$SM.set_state($SM.states.oob)

func enableBoosting():
	if boosting:
		return false
	print(id, " enable boost on frame ", Engine.get_idle_frames())
	boosting = true
	$ThrusterNodes/A.scale = Vector2(.8, .8)
	steer_force += 7
	speed += 60

func disableBoosting():
	boosting = false
	$ThrusterNodes/A.scale = Vector2(0.5, 0.5)
	steer_force += 7
	speed += 60
	boostTimeRemain = 2.0

func getBehaviorVector():
	match state_m.state:
		state_m.states.wander: return seekVector()
		state_m.states.close: return closeVector()
		state_m.states.disengage: return seekVector()
		state_m.states.oob: return seekVector()
		state_m.states.crash: return crashVector()
	return Vector2.ZERO
		
func seekVector():
	var vector_to_target = (moveTarget - global_position).normalized() * speed
	var turn = (vector_to_target - velocity).normalized() * steer_force
	return turn
	
func closeVector(): # closes in towards target
	var desired_velo = moveTarget - global_position
	var d = desired_velo.length()
	if d < 350:
#		print("slowing down")
		desired_velo = desired_velo.normalized() * speed * (d/350)
	else:
		desired_velo = desired_velo.normalized() * speed
		
	return (desired_velo - velocity).normalized() * steer_force
	
func crashVector():
	rotation_degrees += 5 * descentMod
	if descentMod == 1:
		rotation_degrees = max(rotation_degrees + 360, descentTarget + 360)
	else: 
		rotation_degrees = min(rotation_degrees + 360 , descentTarget + 360)
	var dir = Vector2(1, 0).rotated(rotation) * descentSpeed
	return dir

func fireGuns(index):
	if curTarget == null or curTarget.real == false: return
	if weapons[index].canFire():
#		if global_position.distance_to(curTarget.global_position) <= 50: return
		var angleToTarget = rad2deg(curTarget.position.angle_to_point(position))
#		var angle = abs(angleToTarget - rotation_degrees)
#		var fof = weapons[index].fof
		var dif = abs(angleToTarget - rotation_degrees)
		if abs(angleToTarget - rotation_degrees) < weapons[index].fof:
			weapons[index].doFire(curTarget)
			handlePostFire()
	
func handlePostFire():
	return

func getPossibleWeapons(index):
#	return false
#	var weapon = Globals.getSpecificBaseWeaponByName("Light Missile");
	var weapon = Globals.getSpecificBaseWeaponByName("Light Machinecannon");
#	weapon.makeUntargetable()
	weapon.makeInvisible()
	return weapon
	
func getDangerValueFromEntity(display):
	match display:
		"Player":
			return 0.0
		"Fighter":
			return 1.0
		"Helicopter_Light":
			return 1.0
		"Boundary":
			return 15.0
		"Obstacle":
			return 15.0

func setupCrashing():
	var scale = 0.4
	var fire = Globals.getFireNode(scale)
	fire.position = getPointInsideTex()
	var smoke = Globals.getSmokeNode(scale)
	smoke.position = getPointInsideTex()
	addEffectNode(fire)
	addEffectNode(smoke)
	
	for n in 2:
		var explo = Globals.getExplo("wreck", 3)
		explo.set_as_toplevel(true)
		explo.delay = (n+n+1)*3
		get_node("EffectNodes").add_child(explo)
		
	if velocity.x > 0:
		moveTarget = Vector2(global_position.x + 3000, Globals.HEIGHT)
		steer_force -= 140
	elif velocity.x < 0:
		moveTarget = Vector2(global_position.x - 3000, Globals.HEIGHT)
		steer_force -= 140
