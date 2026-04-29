extends Capital
class_name Cargo_Hauler

var display = "Cargohauler"

func setStats():
	.setStats()
	indestructable = true
	
	for n in 10:
		var p = get_point_inside_tex()
		var node = Globals.getFireSmokeNode(1.0, 0.0)
		node.position = p
		$EffectNodes.add_child(node)
	
func adjust_stats_res():
	stats.canCrash = true
	
func process_movement(_delta):
#	if $SM.state == $SM.states.crash:
#		return
		
	set_interest()
	set_danger()
	choose_direction()
	accel = chosen_dir.rotated(rotation) * maxSpeed
	accel = accel.limit_length(maxSpeed)
	velocity += accel * _delta
	velocity = velocity.limit_length(maxSpeed)
	
func getPossibleWeapons(index):
#	var shield = Globals.weapon_shield_dir.instance()
#	var stats = {"maxShield": 60, "shieldRegenTime": 0.5, "shieldBreakTime": 6.0, "shieldFastCharge": 0.75, "shieldDist": 80, "shieldLength": 50}
#	shield.construct(5, "Shield", stats)
#	shield.add_shield_bar()
#	shield.scaleBar("shieldbar", 0.5)
#	return shield

	return get_shield()
	
func get_shield():
	var shield_omni = Globals.weapon_shield_omni.instance()
	
	var stats = {"maxShield": 30, "shieldRegenTime": 1.0, "shieldBreakTime": 4.0, "shieldFastCharge": 1.0, "shieldRadius": 80}
		
	shield_omni.construct(5, "Shield", stats)
	shield_omni.add_shield_bar()
	shield_omni.scaleBar("shieldbar", 0.5)
#	shield_omni.position = Vector2(-15, 0)
#	shield_omni.connect("updateShield_UI_Nodes", mainUI, "_on_updateShield_UI_Nodes")
#	shield_omni.connect("updateShieldBreakCooldown", mainUI, "_on_updateShieldBeakCooldown")
#	shield_omni.shieldbar = Globals.UI.get_node("Bars/Panel/VBox/CC_HealthShield/VBox/Bar_Shield")
	return shield_omni
	

func applyForce(force):
	return

func on_warp_in_done():
	.on_warp_in_done()
	$SM.set_state($SM.states.wander)

func set_new_target():
	pass
	
func kill():
	indestructable = true
	.kill()

func check_hp_post_dmg(amount):
	.check_hp_post_dmg(amount)
	
func x_check_hp_post_dmg(amount):
#	print("check_hp_post_dmg ", get_class())
	if health <= 0:
		kill()
	elif stats.can_withdraw and withdraw_condition(amount):
		enter_withdraw_condition_state()
	elif stats.canCrash and crashCondition(amount):
		enter_crash_condition_state()
	else:
		if smoke < max_smoke:
			var fraction:float = float(health) / maxHealth * 100
			if fraction < dmgBreaks[len(dmgBreaks)-1]:
				dmgBreaks.pop_back()
				smoke += 1
				var scale = get_dmg_gfx_scale()
				add_exp_fire_smoke_fx(scale * rand_range(0.8, 1.2), rand_range(0.4, 0.7))
	return false
