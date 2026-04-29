extends Base_Unit
class_name Air_Unit

func adjust_stats_res():
	stats.canCrash = true
	
#func set_danger():
#	if $SM.state != $SM.states.crash:
#		.set_danger()

func killByCrash():
	print("kill by crash ", get_instance_id())
	destroyed = true
	call_deferred("create_currency")
	set_physics_process(false)
	$SM.enabled = false
	
	for n in $Mounts.get_children():
		n.destroyed = true
		n.get_node("Weapon").doDisable()
		
	if has_node("Tween"):
		if $Tween.is_active(): 
			$Tween.stop_all()
			$Tween.remove_all()
		
	hide_all_control_nodes()
	
	if debug_menu_row != null:
		debug_menu_row.queue_free()
	
	if has_node("Debug"):
		for n in $Debug.get_children():
			n.hide()
		$Debug/C/behav.hide()
		$Debug/C/stats.hide()
		
	var amount = ceil((texDim.x + texDim.y) / 20)
	for n in amount:
		var explo = Globals.getExplo("basic", get_dmg_gfx_scale())
		var pos = get_point_inside_tex()
		explo.position = global_position + pos
		explo.rotation_degrees = Globals.rng.randi_range(0, 359)
		Globals.curScene.get_node("Various").add_child(explo)
		
	for n in (max_smoke):
		add_exp_fire_smoke_fx(0.8, 0.0)
		
	for n in ceil(max_smoke/2):
		add_exp_fire_smoke_fx(0.4, 0.0)
		
func crashCondition(remDmg):
	if $SM.state == $SM.states.crash:
		return false
		
	var rand = rand_range(0, 1)
	var trigger_min = float(maxHealth * stats.crashTresh)
	var cur_health = remDmg / float(health+remDmg)
	if (health < trigger_min and rand < cur_health):
#			print("Crash!")
		print("hit for: ", remDmg, ", health remaining: ", health ,"/", maxHealth)
		print("rand 0-1: ", str(rand), " < than: ", cur_health)
		return true
	
func withdraw_condition(remDmg):
	return false
	
func getCrashSpeed():
	return 0
	
func getCrashAngle():
	return 0
	
func doFaceTarget():
	if curTarget.global_position.x - position.x < 0:
		if $Sprites/Main.flip_h == false:
			doTurnaround()
	else:
		if $Sprites/Main.flip_h == true:
			doTurnaround()

func setupCrashing():
#	invulnerable = true
	danger.fill(0.0)
	for n in max_smoke:
		add_exp_fire_smoke_fx(1.0, rand_range(0, 1) * n*2)
		
	for n in max_smoke:
		var explo = Globals.getExplo("wreck", get_dmg_gfx_scale())
		explo.set_as_toplevel(true)
		explo.offset = get_point_inside_tex()
		explo.delay = rand_range(0.3, 1) * n + 3
		$EffectNodes.add_child(explo)
	
func doInitCrash():
	disableAllThrusterParticles()

	var direction:int = 1
	if $Sprites/Main.flip_h == true:
		direction = -1
	
	var rota = getCrashAngle() * direction
	var time = (Globals.HEIGHT - global_position.y) / getCrashSpeed() / 3
	var targetX = 550 * direction
	$Tween.interpolate_property(self, "position",
		global_position, Vector2(global_position.x + targetX, Globals.HEIGHT - 30), ceil(time),
		Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.interpolate_property(self, "rotation_degrees",
		rotation_degrees, rotation_degrees + rota, ceil(time* 0.9),
		Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.start()
		
func kill():
	if indestructable:
		return
	.kill()
	if position.y < Globals.ROADY - 15:
		hide()
		disableCollisionNodes()

func enableBoosting():
	if boosting:
		return false
	print("enableBooosting")
	boosting = true
	
	var curScale = $ThrusterNodes/Aft.get_node("Particle2D").scale
	
	$Tween.interpolate_property($ThrusterNodes/Aft.get_node("Particle2D"), "scale", curScale, curScale*1.5, 0.4, 0, 2)
	$Tween.start()
	steer_force += boostStrength
	maxSpeed += boostStrength*4

func disableBoosting():
	print("disableBoosting")
	if not boosting:
		return
	boosting = false
	var curScale = $ThrusterNodes/Aft.get_node("Particle2D").scale
	$Tween.interpolate_property($ThrusterNodes/Aft.get_node("Particle2D"), "scale", curScale, curScale/1.5, 0.8, 0, 2)
	$Tween.start()
	steer_force -= boostStrength
	maxSpeed -= boostStrength*4
	boostTimeRemain = 2.0

func setNewWanderTarget():
	var pos = global_position
	var rot = rotation_degrees
	var newTarget = Vector2.ZERO
	var limit = look_ahead + 1
	
	if get_node("Sprites/Main").flip_h == false:
		newTarget = pos + Vector2(300, 70 * Globals.getRandomEntry([1, -1]))
		if newTarget.x > Globals.WIDTH - limit:
			newTarget.x -= 600
	else:
		newTarget = pos + Vector2(-300, 70 * Globals.getRandomEntry([1, -1]))
		if newTarget.x < 0 + limit:
			newTarget.x += 600
#
	if newTarget.y > Globals.HEIGHT:
		newTarget.y -= Globals.HEIGHT
	elif newTarget.y < 0:
		newTarget.y += Globals.HEIGHT
		
#	print(self.display, " #", id, ": movetarget: ", newTarget)
	moveTarget = newTarget
