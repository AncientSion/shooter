extends Weapon_Base
class_name Weapon_Beam

var beamLength:int
var beamWidth:int
var isCharging = false
#var colors = [Color(1, 1, 0, 1), Color(1, 0, 0)]
var colors = [Color(1, 1, 0, 1), Color(0.148438, 1, 0)]


func _ready():
	$Muzzle/AnimatedSprite.hide()
	$Muzzle/BeamCharge.scale = Vector2.ZERO
	$Muzzle/BeamChargeEmitter.emitting = false
	$Muzzle/BeamChargeFireEmitter.emitting = false
	
#	colors[0] = Color(0, 0.226563, 1)
	setColors()

#func _physics_process(delta):
#	print("cooldown left: ", cooldown)
	
func constructWpn(props):
	.constructWpn(props)
	cooldown += lifetime
	rof += lifetime

func setColors():
	
	$Muzzle/BeamChargeEmitter.process_material.color = colors[1].lightened(0.4)
	
	$Muzzle/BeamChargeFireEmitter.process_material.color_ramp.gradient.colors[0] = colors[1].lightened(0.4)
	$Muzzle/BeamChargeFireEmitter.process_material.color_ramp.gradient.colors[1] = colors[1].lightened(0.6)
#	$Muzzle/BeamChargeFireEmitter.process_material.color_ramp.gradient.colors[1] = $Muzzle/BeamChargeFireEmitter.process_material.color_ramp.gradient.colors[0]
#	$Muzzle/BeamChargeFireEmitter.process_material.color_ramp.gradient.colors[1].a = 0
	
	$Muzzle/BeamCharge.texture.gradient.colors[0] = colors[0]
	$Muzzle/BeamCharge.texture.gradient.colors[1] = colors[1]
	
func weapon_process(_delta):
#	print("process weapon")
	.weapon_process(_delta)
	if active and not isCharging and cooldown <= rof:
		handleBeamCharging()

	
func getBeam():
	var beam = Globals.BEAM.instance()
#	beam.construct(faction, dmgType, minDmg, maxDmg, beamLenfgth, beamWidth, lifetime, projNumber, self, shooter)
	beam.constructProj(self)
#	beam.rotation_degrees = global_rotation_degrees + rand_range(-deviation, deviation)
	#shotInstance = beam
	return beam
	
func canBeUnselected():
	return not isFiring
	
func doDisable():
	.doDisable()
#	set_physics_process(false)
	isFiring = false
	isCharging = false
	$Muzzle/BeamCharge.scale = Vector2(0, 0)
	$Muzzle/BeamChargeEmitter.emitting = false
	$Muzzle/BeamChargeFireEmitter.emitting = false
	cooldown = rof
	$Tween.stop_all()
	set_all_cooldown_timers()
	
func doEnable():
	.doEnable()
	if is_processing():
		$Muzzle/BeamChargeEmitter.emitting = true
		cooldown = rof
		set_all_cooldown_timers()
	
func doFire(target):
#	print("doFire")
	.doFire(target)
	isFiring = true
	isCharging = false
	cooldown += lifetime
#	$Muzzle/BeamCharge.scale = Vector2(0, 0)
	$Muzzle/BeamChargeEmitter.emitting = false
	$Muzzle/BeamChargeFireEmitter.emitting = true
	
func setProjRotation(all, current, proj):
	var rota
	
	if linearDevi and deviation != 0:
		rota = - deviation + ((deviation*2) / (all+-1) * current)
	else:
		rota = rand_range(-deviation, deviation)
	
	proj.rotation_degrees =  global_rotation_degrees + rota
	proj.deviation = rota
	
func handleBeamCharging():
	isCharging = true
	isFiring = false
	$Muzzle/BeamChargeEmitter.process_material.emission_sphere_radius = 100
	$Muzzle/BeamChargeEmitter.emitting = true
	$Muzzle/BeamChargeFireEmitter.emitting = false
	
	$Tween.interpolate_property($Muzzle/BeamChargeEmitter.process_material, "emission_sphere_radius",
		100, 40, rof,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

	$Tween.interpolate_property($Muzzle/BeamCharge, "scale",
		Vector2(0, 0), Vector2(1.0, 1.0), rof,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
#
#	if cooldown == rof:
#		print("cooldown = rof, firing false, begin charge")
#		isFiring = false
#		$BeamChargeEmitter.visible = true
#		#$BeamCharge.scale = Vector2(0, 0)
#		$BeamChargeEmitter.process_material.emission_sphere_radius = 100
#
#		$Tween.interpolate_property($BeamChargeEmitter.process_material, "emission_sphere_radius",
#			100, 35, rof,
#			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#
#		$Tween.interpolate_property($BeamCharge, "scale",
#			Vector2(0, 0), Vector2(0.3, 0.3), rof,
#			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#		$Tween.start()
#	elif cooldown == 0:
#		print("cooldown = 0, can fire")
#		#$BeamChargeEmitter.process_material.emission_sphere_radius = 50
#		#$BeamCharge.scale = Vector2(0.4, 0.4)
#
func fillStatsRows():
	subPanel_Stats.addEntry("Cooldown", rof)
	subPanel_Stats.addEntry("Duration", lifetime)
	subPanel_Stats.addEntry("Beams", projNumber)
	subPanel_Stats.addEntry("Range", beamLength)
	subPanel_Stats.addEntry("Damage", str(minDmg, " - ", maxDmg))
	#subPanel_Stats.addEntry("Deviation", deviation)
	return subPanel_Stats

func is_in_range(pos):
	return global_position.distance_to(pos) < beamLength
	
func drawRange():
	draw_arc(Vector2.ZERO, beamLength * 0.5, 0, TAU, 24, Color(1, 0, 0, 1), 1)

func doMuzzleEffect():
	$Muzzle/BeamChargeFireEmitter.emitting = true
	$Tween.interpolate_property($Muzzle/BeamCharge, "scale",
		$Muzzle/BeamCharge.scale, Vector2(0.2, 0.2), lifetime,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	
func get_class():
	return "Weapon_Beam"
	
func getShotDeviation(projNumber, i):
#	var devi = 60
#	var d = - devi + ((devi*2) / (devi+-1) * i)
#	return d
	if linearDevi:
		return - deviation + ((deviation*2) / (projNumber+-1) * i)
	else:
		return rand_range(-deviation, deviation)

func drawAimVector():
	
	var targetUp = Vector2.ZERO
	var targetDown = Vector2.ZERO
	
	targetUp = Vector2(1, 0) * beamLength / 2
	targetDown = Vector2(1, 0) * (beamLength / 2 + 20)
	$Aim/AimA.points[0] = targetUp
	$Aim/AimA.points[1] = targetDown
	
	targetUp = Vector2(1, 0) * (beamLength - 25)
	targetDown = Vector2(1, 0) * (beamLength - 5)
	$Aim/AimB.points[0] = targetUp
	$Aim/AimB.points[1] = targetDown
