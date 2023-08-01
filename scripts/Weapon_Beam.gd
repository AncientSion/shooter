extends Weapon_Base
class_name Weapon_Beam

var beamLength:int
var beamWidth:int
var isFiring = false
var isCharging = false

func construct(init_type:int, init_display:String, init_texture, init_beamLength:int, init_beamWidth:int, init_lifetime:float, init_projNumber:int, init_burst:int, init_rof:float, init_dmg, init_deviation:int):
	type = init_type
	display = init_display
	texture = init_texture
	beamLength = init_beamLength
	beamWidth = init_beamWidth
	lifetime = init_lifetime
	projNumber = init_projNumber
	burst = init_burst
	rof = init_rof
	minDmg = init_dmg.min
	maxDmg = init_dmg.max
	aoe = init_dmg.aoe
	dmgType = init_dmg.dmgType
	deviation = init_deviation
	
	cooldown = init_rof

func _physics_process(_delta):
	#print("_process BEAM #", id)
	if active and not isCharging and cooldown <= rof:
		handleBeamCharging()

func _ready():
#	print("ready BEAM #", id)
	pass
	
func getBeam():
	var beam = Globals.BEAM.instance()
#	beam.construct(faction, dmgType, minDmg, maxDmg, beamLength, beamWidth, lifetime, projNumber, self, shooter)
	beam.constructNew(self)
	#shotInstance = beam
	return beam
	
func canToggle():
	if isFiring: return false
	return true
	
func toggle():
	.toggle()
	#print("toggle	 BEAM #", id)
	isFiring = false
	isCharging = false
	$BeamCharge.visible = active
	$BeamChargeEmitter.visible = active
	$BeamChargeEmitter.emitting = active
	
	#if active:
	cooldown = rof
	setWeaponPanelCooldown()
	
func doFire(target):
	print("doFire")
	.doFire(target)
	isFiring = true
	isCharging = false
	cooldown += lifetime
	$BeamChargeEmitter.visible = false
	$BeamCharge.scale = Vector2(0, 0)
	
func handleBeamCharging():
#	if cooldown == 0:
#		print("cooldown = 0, can fire")
#		#$BeamChargeEmitter.process_material.emission_sphere_radius = 50
#		#$BeamCharge.scale = Vector2(0.4, 0.4)
#	else:w
	#if cooldown == rof:
	#print("cooldown = rof, firing false, begin charge")
	isCharging = true
	isFiring = false
	$BeamChargeEmitter.visible = true
	$BeamCharge.scale = Vector2(0, 0)
	$BeamChargeEmitter.process_material.emission_sphere_radius = 100
	
	$Tween.interpolate_property($BeamChargeEmitter.process_material, "emission_sphere_radius",
		100, 35, rof,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

	$Tween.interpolate_property($BeamCharge, "scale",
		Vector2(0, 0), Vector2(0.3, 0.3), rof,
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
func fillStatsRows(statsPanel):
	statsPanel.addEntry("Cooldown", rof)
	statsPanel.addEntry("Duration", lifetime)
	statsPanel.addEntry("Projs / Burst", str(burst, " x ", projNumber))
	statsPanel.addEntry("Range", beamLength)
	statsPanel.addEntry("Damage", str(minDmg, " - ", maxDmg))
	statsPanel.addEntry("Deviation", deviation)
	return statsPanel

func isInRange(pos):
	return global_position.distance_to(pos) < beamLength
	
func doDisable():
	isFiring = false
	isCharging = false
#	$BeamCharge.visible = false
#	$BeamChargeEmitter.visible = false
#	$BeamChargeEmitter.emitting = false
	.doDisable()
	
func doEnable():
	usable = true
	isCharging = true
#	$BeamCharge.visible = true
#	$BeamChargeEmitter.visible = true
#	$BeamChargeEmitter.emitting = true
