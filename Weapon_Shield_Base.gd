extends Weapon_Base
class_name Weapon_Shield_Base

var baseStats:Dictionary
var shield:int
var maxShield:int
var shieldRadius:int
var shieldRegenTime:float
var shieldBreakTime:float
var shieldFastCharge:float
var shieldLength:int = 36
var shieldDist:int = 60
var is_powering_up:bool = false
var is_breaking: bool = false

const SHIELD_BREAK_TWEEN_TIME:float = 0.6

#var time:float

signal updateShield_UI_Nodes
signal updateShieldBreakCooldown

func _ready():
	add_to_group("isShield")
#	if shieldRegenTime > 0.0:
	$TimerNodes/ShieldRegen.connect("timeout", self, "_on_ShieldRegen_timeout")
	$TimerNodes/ShieldRegen.wait_time = shieldRegenTime
	if shieldBreakTime > 0.0:
		$TimerNodes/ShieldBreak.connect("timeout", self, "_on_ShieldBreak_timeout")
		$TimerNodes/ShieldBreak.wait_time = shieldBreakTime
	$TimerNodes/ShieldBreakUpdateTimer.connect("timeout", self, "_ShieldBreakUpdateTimer_timeout")
	if shieldFastCharge > 0.0:
		$TimerNodes/ShieldSupercharge.connect("timeout", self, "_on_Supercharge_timeout")

func construct(init_type, init_display, stats):
	type = init_type
	display = init_display
	baseStats = stats
	setShieldBaseStats()
	if shieldFastCharge > 0.0:
		shield = 0
	else: 
		shield = maxShield

func setShieldBaseStats():
	for key in baseStats:
		self[key] = baseStats[key]
	
func _physics_process(_delta):
#	if is_breaking:
#		print($Shield.modulate.a)
#		print($Shield.scale)
	pass

func isInActiveBurst():
	return false
	
func canFire():
	return false
	
func set_all_cooldown_timers():
	return
	
#func handleHullDamage(remDmg, pos, angle):
#	return
	
func doUnselect():
	return false
	doDisable()
	setShieldBarHealth()
	
func doDisable():
	unpowerShield()
	.doDisable()
	shield = 0
	updateShield()

func doEnable():
	.doEnable()
	powerShield()

func get_shield_end_scale():
	return Vector2.ZERO
	
func unpowerShield():
	if not active: 
		return
#	shield = 0
#	updateShield()
#	active = false

	is_breaking = true
	
	disableCollisionNodes()
	
	$Tween.interpolate_property($Shield, "modulate:a",
			1.0, 0.0, SHIELD_BREAK_TWEEN_TIME,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
#	
	$Tween.interpolate_property($Shield, "scale",
			get_shield_end_scale(), Vector2(3.5, 3.5), SHIELD_BREAK_TWEEN_TIME,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	$TimerNodes/ShieldRegen.stop()
	
func powerShield():
	if not active:
		return
	active = false
	is_powering_up = true
	is_breaking = false
	print("powering shield on ", display, " #", get_instance_id())
#	active = true
	
	
	var target_charge:int = maxShield * shieldFastCharge
	var charge_tick:float = 0.05
	var total_time:float = (charge_tick * target_charge) + charge_tick

	$TimerNodes/ShieldRegen.wait_time = charge_tick
	$TimerNodes/ShieldRegen.start()
	
#	$Tween.interpolate_property($Shield, "modulate:a",
#			0.0, shieldFastCharge, 0.6,
#			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#	$Tween.start()
#
#	$Tween.interpolate_property($Shield, "scale",
#			Vector2(3.5, 3.5), get_shield_end_scale(), 0.6,
#			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			
	
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property($Shield, "modulate:a", shieldFastCharge, SHIELD_BREAK_TWEEN_TIME)
	tween.tween_property($Shield, "scale", get_shield_end_scale(),SHIELD_BREAK_TWEEN_TIME)
	tween.set_parallel(false)
	tween.tween_callback(self, "powering_up_done")
	
	$TimerNodes/ShieldSupercharge.wait_time = total_time
	$TimerNodes/ShieldSupercharge.start()
#
func powering_up_done():
	is_powering_up = false
	active = true
	enableCollisionNodes()

func powerShield_X():
	if not active:
		return
	print("powering shield on ", display, " #", get_instance_id())
#	active = true
	
	enableCollisionNodes()
	
	var target_charge:int = maxShield * shieldFastCharge
	var charge_tick:float = 0.05
	var total_time:float = (charge_tick * target_charge) + charge_tick

	$TimerNodes/ShieldRegen.wait_time = charge_tick
	$TimerNodes/ShieldRegen.start()

#	$Tween.interpolate_property($Shield, "scale",
#			Vector2(0.0, 0.0), get_shield_end_scale(), 1.0,
#			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#	$Tween.start()

	var tween = get_tree().create_tween()
	$Shield.scale = Vector2.ZERO
	tween.tween_property($Shield, "scale", get_shield_end_scale(), 1.0)
#	tween.tween_callback(self, "warpOutStepTwo")
	
	$TimerNodes/ShieldSupercharge.wait_time = total_time
	$TimerNodes/ShieldSupercharge.start()
#
func _on_Supercharge_timeout():
	$TimerNodes/ShieldRegen.wait_time = shieldRegenTime
	$TimerNodes/ShieldRegen.start()	

func updateShield():
	#print("updateShield")
	setShieldBarHealth()
#	if not is_powering_up:

	if true:
		var factor:float = float(shield) / maxShield
		$Shield.material.set_shader_param("shield_strength", factor)
#		$Shield.modulate.a = factor
	
func doBreakShield():
	unpowerShield()
	shooter.checkForTriggers("on_shieldbreak")
	$TimerNodes/ShieldBreak.start()
	$TimerNodes/ShieldBreakUpdateTimer.start()

func _ShieldBreakUpdateTimer_timeout():
	if $TimerNodes/ShieldBreak.time_left > 0.0:
		$TimerNodes/ShieldBreakUpdateTimer.start()
		setShieldBarBreakTime($TimerNodes/ShieldBreak.time_left)
	
func _on_ShieldRegen_timeout():
#	time -= $TimerNodwwes/ShieldRegen.wait_time
	shield = min(maxShield, shield + 1)
	updateShield()
	$TimerNodes/ShieldRegen.start()
	
func _on_ShieldBreak_timeout():
	$TimerNodes/ShieldBreak.stop()
	$TimerNodes/ShieldBreakUpdateTimer.stop()
	powerShield()

func doInitUI():
	return false

func canBeSelected():
	return false
	
func getRamDamage():
	return shooter.getRamDamage()
	
func takeDamage(entity, totalDmg:int):

	var pos = entity.getPointOfImpact(self)
	var angle = entity.getAttackAngle(self)
	
	shooter.applyForce(-(entity.impactForce).rotated(angle))
	
	var remDmg = totalDmg
	var shieldBefore = self.shield
	
#	print("takeDmg on ", self.display, " totalDmg: ", totalDmg)
	
	if shield > 0:
		shield -= remDmg
		remDmg = 0
		if shield < 0:
			remDmg = -shield
			shield = 0
			
	if remDmg:
		remDmg = max(0, remDmg - self.armor)
#		print("health dmg ", remDmg)
		health -= remDmg
		
	var shieldDmgTaken = shieldBefore - shield
	
	if shieldDmgTaken:
		handle_shield_damage(shieldDmgTaken, pos, angle)
	if remDmg:
		handle_shield_overflow_damage(entity, remDmg)
	emit_signal("damageTaken")
		
func handle_shield_damage(shieldDmgTaken, pos, angle):
	addShieldExplosion(shieldDmgTaken, pos, angle)
	var labelPos = pos + Vector2(0, -(texDim.y/2) -10)
	createFloatingLabel(shieldDmgTaken, labelPos, Vector2(0, -100), false, "00b7ff")
	shooter.checkForTriggers("on_shield_damage")
	updateShield()
	if shield <= 0:
		call_deferred("doBreakShield")
	elif shield < maxShield:
		$TimerNodes/ShieldRegen.start()

func handle_shield_overflow_damage(entity, remDmg):
	print("handleHullDamage on SHIELD")
	self.shooter.takeDamage(entity, remDmg)
	return
