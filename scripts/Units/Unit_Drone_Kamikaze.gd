extends Drone_Shotgun
class_name Drone_Kamikaze

#export var steer_force:int = 30
#var boosting = false
#var boostTimeRemain:float = 2.0

func doInit():
	display = "Drone_Kamikaze"
	.doInit()
	boostStrength = 200
	boostTimeRemain = 2.0
#func doInit():
#	.doInit()
#	rotation = 0.5 * PI
##	var facing = Globals.rng.randi_range(-8, 8)
##	if position.x > Globals.WIDTH / 2:
##		facing += 180
##	velocity = Vector2(1, 0).rotated(deg2rad(facing))
##	rotation = velocity.angle()

func _ready():
	pass

func setSelfFacing(delta):
	if curTarget:
		rotation = curTarget.global_position.angle_to_point(global_position)
	else:
		rotation = velocity.angle()

func doConnect():
	$TimerNodes/BehaveTimer.connect("timeout", self, "doPowerUp")

func doPowerUp():
	.doPowerUp()
	if $SM.state != $SM.states.crash:
		$SM.set_state($SM.states.strike)

func getPossibleWeapons(index):
#	return false
#	var weapon = Globals.getWeaponBase("Super-Light Missile");
#	var weapon = Globals.getWeaponBase("Drone Shotgun");
#	var weapon = Globals.getWeaponBase("Beamlance");
	var weapon = Globals.getWeaponBase("Dummy Weapon");
	weapon.makeInvisible()
	return weapon

func enableBoosting():
	.enableBoosting()
#	print(id, " enableboosting")
	$Sprites/AnimatedSprite.show()
	$Sprites/AnimatedSprite.play()

func disableBoosting():
	if boosting:
#		print(id, " disableBoosting")
		boosting = false
		var curScale = $ThrusterNodes/Aft.get_node("Particle2D").scale
		$Tween.interpolate_property($ThrusterNodes/Aft.get_node("Particle2D"), "scale", curScale, curScale/1.5, 0.8, 0, 2)
		$Tween.start()
		steer_force -= boostStrength
		maxSpeed -= boostStrength*4
		boostTimeRemain = 4.0
		$Sprites/AnimatedSprite.hide()
		$Sprites/AnimatedSprite.stop()
		call_deferred("selfDestruct")
		
func processRamming():
	if not len(rammings):
		return
	selfDestruct()

func selfDestruct():
	print("selfDestruct #", id, " on frame: ", Engine.get_idle_frames())
	var bomb = Globals.BOMB.instance()
	var stats = {"type": 2, "faction": 1, "dmgType": 0, "speed": 700, "minDmg": 20, "maxDmg": 20, "aoe": 70, "lifetime": 0.01, "projNumber": 1,"projSize": 1.0, "recoilForce": Vector2.ZERO}
	stats.recoilForce = Globals.getRecoilForce(stats.minDmg, stats.maxDmg, stats.speed)
	bomb.constructProj(stats)
	bomb.position = global_position
	bomb.disableTriggerCollisionNodes()
	Globals.PROJCONT.add_child(bomb)
	kill()
#	bomb.call_deferred("explode")#bomb.explode()
	
func getCrashSpeed():
	return max(30, maxSpeed / 2)
	
func getCrashAngle():
	return 0
	
func setupCrashing():
	.setupCrashing()
	
	if velocity.x > 0:
#		moveTarget = Vector2(global_position.x + (Globals.HEIGHT-global_position.y)*2, Globals.HEIGHT)
		moveTarget = global_position + Vector2(1, 0).rotated(deg2rad(90 - Globals.rng.randi_range(20, 30)))*Globals.HEIGHT
	elif velocity.x < 0:
#		moveTarget = Vector2(global_position.x - (Globals.HEIGHT-global_position.y)*2, Globals.HEIGHT)
		moveTarget = global_position + Vector2(1, 0).rotated(deg2rad(90 + Globals.rng.randi_range(20, 30)))*Globals.HEIGHT
