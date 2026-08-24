extends Drone_Shotgun
class_name Drone_Kamikaze

#export var steer_force:int = 30
#var boosting = false
#var boostTimeRemain:float = 2.0

func do_specific_unit_init():
	display = ""
	name = display
	boostStrength = 200
	boostTimeRemain = 2.0
	do_connect_unit_signals()

func _ready():
	pass

func setSelfFacing(delta):
	if is_instance_valid(curTarget):
		rotation = (curTarget.global_position - global_position).angle()
	elif velocity.length_squared() > 1:
		rotation = velocity.angle()

#func do_connect_unit_signals():
#	return
#	$TimerNodes/Power_up_timer.connect("timeout", self, "do_power_up")
#	print("time: ", $TimerNodes/Power_up_timer.wait_time)

func do_power_up():
	.do_power_up()
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

func enable_boosting():
	.enable_boosting()
#	print(id, " enable_boosting")
	$Sprites/AnimatedSprite.show()
	$Sprites/AnimatedSprite.play()

func disable_boosting():
	if boosting:
#		print(id, " disable_boosting")
		boosting = false
		var curScale = $ThrusterNodes/Aft.get_node("Particle2D").scale
		$Tween.interpolate_property($ThrusterNodes/Aft.get_node("Particle2D"), "scale", curScale, curScale/1.5, 0.8, 0, 2)
		$Tween.start()
		steer_force -= boostStrength
		maxSpeed -= boostStrength*4
		boostTimeRemain = 2.0
		$Sprites/AnimatedSprite.hide()
		$Sprites/AnimatedSprite.stop()
		call_deferred("selfDestruct")
		
func processRamming(delta):
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
	
func crash_step_one():
	.crash_step_one()
	
	if velocity.x > 0:
#		moveTarget = Vector2(global_position.x + (Globals.HEIGHT-global_position.y)*2, Globals.HEIGHT)
		moveTarget = global_position + Vector2(1, 0).rotated(deg2rad(90 - Globals.rng.randi_range(20, 30)))*Globals.HEIGHT
	elif velocity.x < 0:
#		moveTarget = Vector2(global_position.x - (Globals.HEIGHT-global_position.y)*2, Globals.HEIGHT)
		moveTarget = global_position + Vector2(1, 0).rotated(deg2rad(90 + Globals.rng.randi_range(20, 30)))*Globals.HEIGHT
