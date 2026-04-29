extends Air_Unit
class_name Bomber

var display = "Bomber"
var engine = 300
	
func do_specific_unit_init():
#	.doInit()
	var facing = Globals.rng.randi_range(-0, 0)
	steer_force = 6
	if position.x > Globals.WIDTH / 2:
		facing += 180
	velocity = Vector2(1, 0).rotated(deg2rad(facing))
	rotation = velocity.angle()
#	speed = 220
	minSpeed = maxSpeed * 0.9
	
func _ready():
	$ThrusterNodes/Aft/Particle2D.process_material.scale = 2

func _physics_process(_delta):
	pass
	
func set_direction(_dirVector = false):
	pass
	
#func missile_move_logic(delta):
#	accel += seek()
#	accel = accel.limit_length(accelLimit)
#	velocity += accel * delta
#	velocity = velocity.limit_length(speed)
##	print("missile #", get_instance_id(), " rotation_degrees: ", rotation_degrees)
#	rotation = velocity.angle()
##	print("missile #", get_instance_id(), " rotation_degrees: ", rotation_degrees)
#	position += velocity * delta
#
#	if homeTimer > 0.0:
#		homeTimer -= delta
#		if homeTimer < 0.0:
#			homing = true
#			speed *= 2
#
#	if displaceTimer > 0.0:
#		displaceTimer -= delta
#		if displaceTimer <= 0.0:
#			displaceForce = rand_range(displaceForceBase, displaceForceBase*2) * Globals.getRandomEntry([1, -1])
#			displaceTimer = displaceTimerBase
#
#func seek(): 
#	var steer = Vector2.ZERO
#
#	var desired = (target.position - position).normalized() * speed
#	steer = (desired - velocity).normalized() * steerForce
#	return steer



func process_movement(_delta):
#	print(rotation)
	set_interest()
	set_danger()
	choose_direction()
	accel += chosen_dir.rotated(rotation) * engine
#	accel = accel.normalized() * maxSpeed
	accel = accel.limit_length(engine)
	
	var dot = abs(velocity.normalized().dot(accel.normalized()))
	var air_resistance_factor = dot * 0.3
	var minimum_momentum_factor = 0.7

	velocity += accel * _delta
	velocity = velocity.normalized() * maxSpeed
	velocity *= air_resistance_factor + minimum_momentum_factor

#	# Calculate the desired rotation angle based on velocity
#	var desiredRotation = velocity.angle()
#
#	# Calculate the angle difference between current and desired rotation
#	var angleDifference = shortest_angle_dist(rotation, desiredRotation)

	# Apply rotation based on angular acceleration
#	var angularAcceleration = 1.0
#	var maxAngleChange = angularAcceleration * _delta
#	var rotationChange = clamp(angleDifference, -maxAngleChange, maxAngleChange)
#	rotation += rotationChange
	rotation = velocity.angle()
#	print(rotation)
	
func shortest_angle_dist(from: float, to: float) -> float:
	var twoPi = TAU
	var delta = fmod(to - from, twoPi)
	if delta > PI:
		delta -= twoPi
	elif delta < -PI:
		delta += twoPi
	return delta
		
func enableBoosting():
	return false
		
func setUnitFacing():
	if velocity.x < 0 and sprite.flip_v == false:
		sprite.flip_v = true
		mirrorTurrets()
		mirrorThrusters()
#		mirrorVarious()
#		mirrorColNodes()
	elif velocity.x > 0 and sprite.flip_v == true:
		sprite.flip_v = false
		mirrorTurrets()
		mirrorThrusters()
#		mirrorVarious()
#		mirrorColNodes()
		
func mirrorThrusters():
	for n in $ThrusterNodes.get_children():
		n.position.y *= -1
		
func mirrorTurrets():
	$Mounts.scale.y *= -1
	return
	for n in $Mounts.get_children():
		n.position.x *= -1
#		if not n.has_node("Weapon"): return
		var weapon = n.get_node("Weapon")
		weapon.anchor.x *= -1
		weapon.current_rot.x *= -1
		weapon.rotation = weapon.current_rot.angle()
	
#func fireGuns(weapon):
#	if curTarget == null or curTarget.real == false: return
#	if weapon.canFire():
##		if global_position.distance_to(curTarget.global_position) <= 50: return
#		var angleToTarget = rad2deg(curTarget.position.angle_to_point(position))
##		var angle = abs(angleToTarget - rotation_degrees)
##		var fof = weapons[index].fof
#		var dif = abs(angleToTarget - rotation_degrees)
#		if abs(angleToTarget - rotation_degrees) < weapon.fof:
#			weapon.doFire(curTarget)
			
func fireGunsx(weapon):
	if curTarget == null or curTarget.real == false: return
	if weapon.canFire():
#		if global_position.distance_to(curTarget.global_position) <= 50: return
#		var angleToTarget = rad2deg(curTarget.position.angle_to_point(position))
		var angleToTarget = rad2deg(moveTarget.angle_to_point(position))
#		var angle = abs(angleToTarget - rotation_degrees)
#		var fof = weapons[index].fof
		var dif = abs(angleToTarget - rotation_degrees)
		if abs(angleToTarget - rotation_degrees) < weapon.fof:
			var d = global_position.distance_to(moveTarget)
			var tSpeed = curTarget.velocity.length()
			var etaA = d / $Mounts/A.get_node("Weapon").speed
			var etaB:float = 0.0
			if tSpeed > 0:
				etaB = curTarget.global_position.distance_to(moveTarget) / tSpeed
				if etaA * 0.8 < etaB and etaA * 1.2 > etaB:
					weapon.doFire(curTarget)
			else:
				weapon.doFire(curTarget)

func getPossibleWeapons(index):
	return false
#	var weapon = Globals.getWeaponBase("Light Missile");
	var weapon:Weapon_Base
	match index:
#		0:
#			weapon = Globals.getWeaponBase("Light Machinecannon");
#			weapon.fof = 9
#			weapon.rof = 1
		0:
			weapon = Globals.getWeaponBase("Light Bomb");
			weapon.fof = 30
#			weapon.steerForce *= 1.5
	weapon.makeInvisible()
	return weapon
	
func addStartingItems():
#	addItem(Globals.getItemBase("Minelayer (Passive)"))
	var item = Globals.getItemBase("Conv. Bomb Rack (A)")
	item.result[0].minDmg *= 0.6
	item.result[0].maxDmg *= 0.6
	item.result[0].stacks = 3
	item.result[0].speed = 50
#	item.scaleDmg(0.3)
	addItem(item)
	
func initAvoidValues():
	avoidValues = {"Player": 1.0, "Fighter": 1.0, "Helicopter_Light": 1.0, "Boundary": 5.0, "Obstacle": 5.0, "Cargohauler": 3.5, "City": 0.0}
		
func setupCrashing():
	.setupCrashing()
	if rotation_degrees > 55 and rotation_degrees < 125:
		moveTarget = global_position + (Vector2.RIGHT.rotated(rotation + rand_range(-0.3, 0.3)) * 1000)
	elif velocity.x > 0:
		moveTarget = Vector2(global_position.x + global_position.y*2, Globals.HEIGHT)
	elif velocity.x < 0:
		moveTarget = Vector2(global_position.x - global_position.y*2, Globals.HEIGHT)

func killByCrash():
	kill()
	$ThrusterNodes/Aft/Particle2D.emitting = false

func setNewWanderTarget():
		
	var pos = global_position
	var rot = rotation_degrees
	var newTarget = Vector2.ZERO
	var limit = 400
	
	if rotation_degrees > -90 and rotation_degrees < 90:
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
	
	moveTarget = newTarget
	
#func setup_delayed_warp_in(time):
#	print("setup_delayed_warp_in for ", self.display, ": ", time, " seconds.")
