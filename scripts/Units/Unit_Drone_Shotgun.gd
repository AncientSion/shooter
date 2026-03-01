extends Air_Unit
class_name Drone_Shotgun

var display = "Drone_Shotgun"
	
#func doInit():
#	.doInit()
#	rotation = 0.5 * PI
##	var facing = Globals.rng.randi_range(-8, 8)
##	if position.x > Globals.WIDTH / 2:
##		facing += 180
##	velocity = Vector2(1, 0).rotated(deg2rad(facing))
##	rotation = velocity.angle()

func _ready():
	$ThrusterNodes/Aft/Particle2D.process_material.scale = 2
	pass
	
func doInit():
	.doInit()
#	boostStrength = 60
#	$ThrusterNodes/Aft/Particle2D.process_material.scale = 3
	doConnect()

func doConnect():
	if has_node("Mounts/A"):
		$Mounts/A.get_node("Weapon").connect("hasFired", self, "on_hasFired")
	$TimerNodes/BehaveTimer.connect("timeout", self, "doPowerUp")

func on_hasFired():
	doPowerDown()
	
func doPowerDown():
	maxSpeed = 0
	accel = Vector2.ZERO
	$ThrusterNodes/Aft/Particle2D.emitting = false
	$Tween.interpolate_property(self, "velocity", velocity, velocity/10, 1.0,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	$TimerNodes/BehaveTimer.start()
	
func doPowerUp():
	$ThrusterNodes/Aft/Particle2D.emitting = true
	maxSpeed = 200
	
func _physics_process(_delta):
	pass
	
func setDirection(_dirVector = false):
	pass
	
func process_movement(_delta):
	set_interest()
	set_danger()
	choose_direction()
	accel += chosen_dir.rotated(rotation) * maxSpeed
	accel = accel.limit_length(maxSpeed * 2)
	velocity += accel * _delta
	velocity = velocity.limit_length(maxSpeed)
	if velocity.length() < minSpeed:
		velocity = velocity.normalized() * minSpeed
		
	if $SM.state == $SM.states.crash:
		rotation = lerp_angle(rotation, PI/2, 0.005)
	elif maxSpeed > 0:
		setSelfFacing(_delta)

	if boosting:
		boostTimeRemain -= _delta
		if boostTimeRemain <= 0:
			disableBoosting()

func setSelfFacing(_delta):
#	var forwardV = Vector2(cos(rotation), sin(rotation))
#	rotation = forwardV.move_toward((Globals.MOUSE - global_position), _delta * agility).angle()
	var rotSpeed = 4.0
	var dir = Vector2.ZERO
	if curTarget:
		dir = curTarget.global_position - global_position
	else:
		dir = moveTarget - global_position
	var angleTo = transform.x.angle_to(dir)
	rotate(sign(angleTo) * min(_delta * rotSpeed, abs(angleTo)))

func setSelfFacingx():
	if curTarget:
		rotation = curTarget.global_position.angle_to_point(global_position)
	else:
		rotation = velocity.angle()
	
#	var omega = forwardV.angle_to((Globals.MOUSE - global_position))
#	var change
	
	
func setUnitFacing():
	return
	if velocity.x < 0:
		sprite.flip_v = true
	else:
		sprite.flip_v = false

func getPossibleWeapons(index):
#	return false
#	var weapon = Globals.getWeaponBase("Super-Light Missile");
	var weapon = Globals.getWeaponBase("Drone Shotgun");
#	var weapon = Globals.getWeaponBase("Beamlance");
	weapon.makeInvisible()
	return weapon
	
func getCrashSpeed():
	return max(30, maxSpeed / 2)
	
func getCrashAngle():
	return 0
	
func setupCrashing():
	.setupCrashing()
	doPowerUp()
	$ThrusterNodes/Aft/Particle2D.emitting = false
	
	if velocity.x == 0:
#		velocity.x = Globals.rng.randi_range(-1, 1)
		velocity.x = Globals.getRandomEntry([-1, 1])
		
	if velocity.x > 0:
		moveTarget = global_position + Vector2(1, 0).rotated(deg2rad(90 - Globals.rng.randi_range(20, 30)))*Globals.HEIGHT
	elif velocity.x < 0:
		moveTarget = global_position + Vector2(1, 0).rotated(deg2rad(90 + Globals.rng.randi_range(20, 30)))*Globals.HEIGHT

func killByCrash():
	.killByCrash()
		
	for n in 1:
		add_exp_fire_smoke_fx(0.3, 0.0)
		
	for n in 1:
		var explo = Globals.getExplo("radial", get_dmg_gfx_scale())
		explo.position += position + get_point_inside_tex()
		explo.rotation = Globals.rng.randi_range(0, 2*PI)
		Globals.curScene.get_node("Various").add_child(explo)
	
	if global_rotation_degrees > -90 and global_rotation_degrees < 90:
		global_rotation_degrees = Globals.rng.randi_range(4, 10)
	else:
		$Sprites/Main.flip_h = true
		global_rotation_degrees = - Globals.rng.randi_range(4, 10)

	for n in $EffectNodes.get_children():
		n.rotation = -rotation

func setNewWanderTarget():
	var pos = global_position
	var rot = rotation_degrees
	var limit = look_ahead + 1
	
	var change = Vector2.RIGHT.rotated(deg2rad(Globals.rng.randi_range(30, 60) * Globals.getRandomEntry([1, -1]))) * 600
	moveTarget = pos + change
	if moveTarget.y < 300:
		moveTarget.y += 500
	elif moveTarget.y > Globals.ROADY - 300:
		moveTarget.y -= 500
		
	if moveTarget.x < 300:
		moveTarget.x += 600
	elif moveTarget.x > Globals.WIDTH - 300:
		moveTarget.x -= 600
