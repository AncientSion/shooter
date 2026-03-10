extends Base_Entity
class_name Base_Unit

export(Resource) var stats

var wave_strength:int = 0

var interest = []
var danger = []
var ray_directions = []
var ray_degree = []
var chosen_dir = Vector2.ZERO
var avoidValues = []

var num_rays:int
var look_ahead:int
var toching_bound:bool = false

var moveTarget = Vector2.ZERO
var startPos = Vector2.ZERO
var direction = Vector2.ZERO
var accel = Vector2.ZERO
var velocity = Vector2.ZERO
var extForces = Vector2.ZERO
var gravity_vec = Vector2.ZERO
var aWeapon:int = 0
var items = []

var sightRange:int = 0
var coreRange:int = 50

var escalation:int = 0
var boosting:bool = false
var aft_boosting:bool = false
var front_boosting:bool = false
var boostStrength:int = 0
var boostTimeRemain:float = 0
var steer_force:int = 0

var ready = true
var dmgBreaks = []

var ram

onready var sprite = $Sprites/Main
onready var state_m = $SM

var dir_update_frames:int = 12

func _ready():
	add_to_group("isUnit")
	set_physics_process(true)
	
func initAvoidValues():
	pass
	
func addSightCollision():
	
	var maxSight:int = 0
	
	for mount in $Mounts.get_children():
#		if mount.has_node("Weapon"):
		maxSight = max(maxSight, mount.get_node("Weapon").getMaxRange())
#	print(self.display, " ", maxSight, " maxSight")
	if not has_node("Sight"): 
		return
	var sight = CollisionShape2D.new()
	sight.name = "CollisionShape2D"
	sight.shape = CircleShape2D.new()
	sight.shape.radius = sightRange
	$Sight.add_child(sight)
	
func addPhysCollision():
	var phys = CollisionShape2D.new()
	phys.name = "CollisionShape2D"
	phys.shape = CircleShape2D.new()
	phys.shape.radius = coreRange
	$Phys.add_child(phys)

func setMass():
	health = maxHealth
	mass = stepify(pow(maxHealth, 1.2), 0.01)
#	print(self.display, ": ", mass, " mass")

func getDamageObject():
#	print("error getDamageObject")
	return ram
	
func setDamageBreaks():
#	print("setDamageBreak: ", self.display)
	for n in maxSmoke:
		dmgBreaks.append(100/(maxSmoke+1)*(n+1))
#	print(dmgBreaks)
	
func check_hp_post_dmg(amount):
#	print("check_hp_post_dmg ", get_class())
	if health <= 0:
		kill()
	elif stats.can_withdraw and withdraw_condition(amount):
		enter_withdraw_condition_state()
	elif stats.canCrash and crashCondition(amount):
		enter_crash_condition_state()
	else:
		if smoke < maxSmoke:
			var fraction:float = float(health) / maxHealth * 100
			if fraction < dmgBreaks[len(dmgBreaks)-1]:
				dmgBreaks.pop_back()
				smoke += 1
				var scale = get_dmg_gfx_scale()
				add_exp_fire_smoke_fx(scale * rand_range(0.8, 1.2), rand_range(0.4, 0.7))
	return false
		
func enter_withdraw_condition_state():
	check_support_duration()
	if canWarp:
		$SM.set_state($SM.states.prepareWarpOut)
		$SM.canChangeState = false
	else:
		$SM.set_state($SM.states.withdraw)
	
func enter_crash_condition_state():
	check_support_duration()
	$SM.canChangeState = false
	$SM.set_state($SM.states.crash)
	
func setupCrashing():
	pass

func crashCondition(remDmg):
	return false
	
func withdraw_condition(remDmg):
	return false
	
func init_lifetime():
	if lifetime <= 0.0:
		return
	
	var timer = Timer.new()
	timer.name = "rem_lifetime"
	timer.wait_time = lifetime
	timer.connect("timeout", self, "_on_support_duration_timeout", [timer])
	get_node("TimerNodes").add_child(timer)
	
	var node = Globals.TEXT_LABEL.instance()
	node.name = "rem_lifetime_label"
	node.offset = Vector2(0, max(40, texDim.y + 10))
	node.init_text_label_string(lifetime)
	$ControlNodes.add_child(node)
	
	check_controlnodes_top_level()
	
func check_support_duration():
	if has_node("ControlNodes/rem_lifetime_label") and get_node("ControlNodes/rem_lifetime_label").isUpdating:
		get_node("TimerNodes/rem_lifetime").stop()
		get_node("ControlNodes/rem_lifetime_label").isUpdating = false

func doInit():
	maxSmoke = ceil(texDim.length() / 100)
	setDamageBreaks()
	randomizeWeaponStartCooldown()
	init_lifetime()
	showDebug()
	init_debug_menu_entry()
	addPhysCollision()
	addSightCollision()
	initSteering()
	initAvoidValues()
#	do_init_mounts()
#	$SM.do_init()

func set_wave_strength(strength):
	wave_strength = strength
	
func do_init_mounts():
	for n in $Mounts.get_children():
		n.do_init()
	
func showDebug():
	
	if not has_node("Debug"):
		return
	$Debug/moveTarget.set_as_toplevel(true)
	$Debug/moveTarget.show()
	$Debug/MoveTargetVector.set_as_toplevel(true)
	$Debug/MoveTargetVector.show()
	$Debug/C/stats.set_as_toplevel(true)
	$Debug/C/stats.show()
	$Debug/C/behav.set_as_toplevel(true)
	$Debug/C/behav.show()
	
	if not $Debug.visible:
		$Debug/moveTarget.hide()
		$Debug/MoveTargetVector.hide()
		$Debug/C/stats.hide()
		$Debug/C/behav.hide()
		
func hideDebug():
	if not has_node("Debug"):
		return
	$Debug/moveTarget.set_as_toplevel(false)
	$Debug/moveTarget.hide()
	$Debug/MoveTargetVector.set_as_toplevel(false)
	$Debug/MoveTargetVector.hide()
	$Debug/C/stats.set_as_toplevel(false)
	$Debug/C/stats.hide()
	$Debug/C/behav.set_as_toplevel(false)
	$Debug/C/behav.hide()
	
func randomizeWeaponStartCooldown():
	return
	for mount in $Mounts.get_children():
		var weapon = mount.get_node("Weapon")
		if weapon.rof != 0:
			weapon.cooldown = rand_range(0, weapon.rof*2)

func _process(_delta):
	if isWarping:
		$Jump.position = global_position

func _draw():
	if Globals.SIGHTDEBUG:
		drawSight()
		drawCore()

func drawSight():
	draw_arc(Vector2.ZERO, sightRange, 0, TAU, 24, Color(0, 0, 1, 1), 1)
	
func drawCore():
	return
	draw_arc(Vector2.ZERO, coreRange, 0, TAU, 24, Color(1, 1, 0, 1), 1)
			
func _physics_process(_delta):
	if destroyed or not ready: 
		return
		
	updateDebugList()
	update_debug_menu_entry()
	$SM._process_state_logic(_delta)
		
	if toching_bound:
		bound_process(_delta)
	
	velocity += gravity_vec * _delta
	position += extForces * _delta
#	position += gravity_vec * _delta
	position += velocity * _delta
	setUnitFacing()

#	accel *= 0.99
	velocity *= .99
	
#	if moveTarget == null:
#		accel *= .99

	if extForces:
		if extForces.length() < 4:
			extForces = Vector2.ZERO
		extForces *= 0.97
#	else:
#		velocity += gravity_vec * _delta
		
	handle_weapons(_delta)
	handleItems(_delta)
	
#func handleControlNodes():
#	for n in $ControlNodes.get_children():
#		n.rect_position = global_position + n.offset
		
func process_movement(_delta):
	pass
	
func bound_process(_delta):
	pass
	
func get_weapon_by_index(index:int):
	return $Mounts.get_child(index).get_node("Weapon")

func handle_weapons(_delta): # context: unit with several weapon mounts
	for n in $Mounts.get_children(): 
		var weapon = n.get_node("Weapon")
		if not is_instance_valid(weapon) or weapon.destroyed or not weapon.active:
			continue
		if not weapon.wpn_has_valid_target(): # does it NOT have a target ?
			weapon.set_wpn_target(targetsArr) # if so, assign a valid target to this weapon
		if weapon.curTarget == null: # if it still has no target, next
			continue
		weapon.do_track_target() # it has a target, rotate the weapon towards it
		if weapon.canFire(): # check cooldown, emp or other conditions
			if weapon.bursting or weapon.hasViableFireSolution(): # do i have the right vector / rotation achieved `?
				weapon.handleFiring() # spawn projectile
				
func handleItems(_delta):
	for n in $Items.get_children():
		n.item_use_check_process(_delta)
		
func init_debug_menu_entry():
	if debug_menu_row != null: return
	debug_menu_row = Globals.curScene.get_node("UI/Place/Topright/AI_PC/VBoxC/HBox").duplicate()
	Globals.curScene.get_node("UI/Place/Topright/AI_PC/VBoxC").add_child(debug_menu_row)
	debug_menu_row.get_node("name/label").text = str("#",self.id, ": ", self.display)
	debug_menu_row.get_node("extF/label").text = str("")
	debug_menu_row.get_node("behavior/label").text = str($SM.state)
	debug_menu_row.get_node("target/label").text = str(getTargetDisplay())
	debug_menu_row.get_node("hp/label").text = str(health, "/", maxHealth)
	update_debug_menu_entry()
		
func update_debug_menu_entry():
	if debug_menu_row != null:
		debug_menu_row.get_node("pos/label").text = str(round(position.x), " / ", round(position.y))
		debug_menu_row.get_node("velo/label").text = str(round(velocity.length()))
		debug_menu_row.get_node("accel/label").text = str(accel.round(), ", ", round(accel.length()))
		debug_menu_row.get_node("extF/label").text = str(extForces.round())
#		var keys = $UnitSM.states.keys()
#		print(keys)

func update_debug_menu_entry_on_state_change():
	if debug_menu_row != null and is_instance_valid(debug_menu_row):
		debug_menu_row.get_node("behavior/label").text = str($SM.states.keys()[$SM.state])
		debug_menu_row.get_node("target/label").text = str(getTargetDisplay())
		
func mark_debug_menu_entry_as_killed():
#	debug_menu_row.theme_type_variation = "label_font_red"
	for n in debug_menu_row.get_children():
		n.get_node("label").theme_type_variation = "label_font_red"
#	debug_menu_row.get_node("name/label").theme_type_variation = "label_font_red"

func mark_debug_menu_entry_as_removed():
#	debug_menu_row.theme_type_variation = "label_font_red"
	for n in debug_menu_row.get_children():
		n.get_node("label").theme_type_variation = "label_font_yellow"
#	debug_menu_row.get_node("name/label").theme_type_variation = "label_font_red"

func updateDebugList():
	$Debug/C/behav.rect_position = global_position + Vector2(-30, 50)
	$Debug/C/stats.rect_position = global_position + Vector2(-30, 100)
	$Debug/C/stats.text = str("#", id, "\n", accel.round())
	
	if moveTarget:
		$Debug/moveTarget.rect_position = moveTarget - Vector2(20, 10)
		$Debug/MoveTargetVector.points[0] = global_position
		$Debug/MoveTargetVector.points[1] = moveTarget

func getTargetDisplay():
	if curTarget == null or not is_instance_valid(curTarget):
		return null
	else: return curTarget.display
		
func checkMoveTargetWithinBoundary():
	if $SM.state != $SM.states.crash:
		moveTarget.x = clamp(moveTarget.x, 300, Globals.WIDTH - 300)
		moveTarget.y = clamp(moveTarget.y, 300, Globals.HEIGHT - 300)
	pass
		
func enableAllCollisionNodes():
	enableCollisionNodes()
	for n in $Mounts.get_children():
		if n.health > 0:
			n.enableCollisionNodes()

func disableAllCollisionNodes():
	disableCollisionNodes()
	for n in $Mounts.get_children():
		n.disableCollisionNodes()

func setActive():
#	print("set active: ", self.display)
	ready = true
	set_physics_process(true)
	enableItems()
	enableAllCollisionNodes()
	
	for n in $Mounts.get_children():
		n.get_node("Weapon").doEnable()
		
	for n in $ThrusterNodes.get_children():
		n.visible = true
	
#	if debug_menu_row != null and is_instance_valid(debug_menu_row):
#		debug_menu_row.show()

	if target_indicator and is_instance_valid(target_indicator):
		target_indicator.enable()
		
	$SM.do_init()
		
func setInactive():
#	print("set setInactive: ", self.display)
	ready = false
	set_physics_process(false)
	disableItems()
	disableAllCollisionNodes()

	for n in $Mounts.get_children():
		n.get_node("Weapon").doDisable()
		
	for n in $ThrusterNodes.get_children():
		n.visible = false
	
#	if debug_menu_row != null and is_instance_valid(debug_menu_row):
#		debug_menu_row.hide()

	if target_indicator and is_instance_valid(target_indicator):
		target_indicator.disable()
	
func setUnitFacing():
	return
	
func setStats():
	stats = stats.duplicate()
	adjustStatsRes()
	
	maxHealth = stats.health
	armor = stats.armor
	maxSpeed = stats.maxSpeed
	minSpeed = stats.minSpeed
	lootValue = stats.lootValue
	sightRange = stats.sightRange
	look_ahead = stats.look_ahead
	num_rays = stats.num_rays
	
func adjustStatsRes():
	pass

func hideSelf():
	hide()
	for mount in $Mounts.get_children():
#		if mount.has_node("Weapon"):
		mount.get_node("ControlNodes").hide()
		mount.get_node("Weapon/ControlNodes").hide()
		
func setupDelayedWarpIn(time):
	print("setupDelayedWarpIn for ", self.display, ": ", time, " seconds.")
	hideSelf()
	setInactive()
	var timer = Timer.new()
	timer.name = "WarpInTimer"
	$TimerNodes.add_child(timer)
#	$Globals.curScene.add_child(timer)
	timer.connect("timeout", self, "doDelayedWarpIn", [timer])
	timer.wait_time = time
	timer.start()
	$Jump.visible = true
	
func can_warp_in():
	return false
	
func setupDelayedWarpOut(time):
	print("setupDelayedWarpOut for ", self.display, ": ", time, " seconds.")
	var timer = Timer.new()
	timer.name = "WarpOutTimer"
	$TimerNodes.add_child(timer)
#	Globals.curScene.add_child(timer)
	timer.connect("timeout", self, "doDelayedWarpOut", [timer])
	timer.wait_time = time
	timer.start()

func doDelayedWarpIn(timer):
	timer.queue_free()
	doWarpIn()
	
func doWarpIn():
	warpInStepOne()

func warpInStepOne():
	isWarping = true
	$Jump.scale = Vector2.ZERO

	var durIn = 1.0 * Globals.mod / 5
	var tween = get_tree().create_tween()
	
	tween.tween_property($Jump, "scale", Vector2(10, 1), durIn)
	tween.tween_property($Jump, "scale", Vector2(20, 15), durIn)
	tween.tween_callback(self, "warpInStepTwo")

func warpInStepTwo():
	show()
	$Sprites.scale = Vector2.ZERO
	$Sprites.modulate.a = 0.0
	$Mounts.scale = Vector2.ZERO
	$Mounts.modulate.a = 0.0
	$ThrusterNodes.visible = true
	$Mounts.visible = true

	var durOut = 1.0 * Globals.mod / 5
	var tween = get_tree().create_tween().set_parallel(true)

	tween.tween_property($Jump, "scale", Vector2(0, 0), durOut)
	tween.tween_property($Sprites, "scale", Vector2(1, 1), durOut/2)
	tween.tween_property($Sprites, "modulate:a", 1.0, durOut)
	tween.tween_property($Mounts, "scale", Vector2(1, 1), durOut/2)
	tween.tween_property($Mounts, "modulate:a", 1.0, durOut)
	tween.set_parallel(false)
	tween.tween_callback(self, "onWarpInDone")
	
func onWarpInDone():
#	print(self.display, ": onWarpInDone")
	emit_signal("hasWarpedIn")
	isWarping = false
	$Jump.scale = Vector2(1, 1)
	$Jump.visible = false
	$Jump.modulate.a = 1
	
	setActive()
	showAllControlNodes()
	enableWeapons()
	enableItems()
	
	if lifetime > 0.0:
		$TimerNodes.get_node("rem_lifetime").start()
		$ControlNodes.get_node("rem_lifetime_label").isUpdating = true
		
func doDisableShield():
	$Mounts/A/.get_child(0).unpowerShield()
	
func cancelWarpOut():
	print("cancelWarpOut")
		
func doDelayedWarpOut(timer):
	timer.queue_free()
	warpOutStepOne()
	
func warpOutStepOne():
	print("warpOutStepOne")
	isWarping = true
	$Jump.visible = true
	doUnselectWeapons()
	var durOut = 1.0 * Globals.mod / 5
	var tween = get_tree().create_tween()
	
	tween.tween_property($Jump, "scale", Vector2(20, 15), durOut)
	tween.tween_callback(self, "warpOutStepTwo")
	
func warpOutStepTwo():
	print("warpOutStepTwo")
	$EffectNodes.visible = false
	$ControlNodes.visible = false
	for n in $Mounts.get_children():
		n.get_node("Weapon/ControlNodes").visible = false
	$ThrusterNodes.visible = false
	$Mounts.visible = false
	
	var durIn = 2.0 * Globals.mod / 5
	var durOut = 1.0 * Globals.mod / 5
	var tween = get_tree().create_tween().set_parallel(true)
	
	tween.tween_property($Jump, "scale", Vector2(10, 1), durIn)
	tween.tween_property($Sprites, "modulate:a", 0.0, durOut)
	tween.tween_property($Sprites, "scale", Vector2(0, 0), durOut/2)
	tween.tween_property($Mounts, "modulate:a", 0.0, durOut)
	tween.tween_property($Mounts, "scale", Vector2(0, 0), durOut/2)
	tween.set_parallel(false)
	tween.tween_callback(self, "warpOutStepThree")
	
func warpOutStepThree():
	print("warpOutStepThree")
	var durIn = 2.0 * Globals.mod / 5
	var tween = get_tree().create_tween()
	
	tween.tween_property($Jump, "scale", Vector2(0, 0), durIn)
	tween.tween_callback(self, "onWarpOutDone")
	
func onWarpOutDone():
	print(self.display, ": onWarpOutDone")
	emit_signal("hasWarpedOut")
	isWarping = false
#	return
	setInactive()
	unload_gear()
	hideAllControlNodes()
	hideDebug()
	velocity = Vector2.ZERO
	extForces = Vector2.ZERO
	accel = Vector2.ZERO
	
	$Mounts.modulate.a = 1.0
	$Mounts.scale = Vector2(1, 1)
	
	if isTarget:
		unmarkAsTarget()
	elif isProtect:
		unmarkAsProtect()
	
	if has_node("Debug") and get_node("Debug").visible:
		get_node("Debug").hide()
	
func showAllControlNodes():
	if not isPlayer:
		if has_node("ControlNodes"):
			has_ControlNodes = true
			$ControlNodes.visible = true
		for mount in $Mounts.get_children():
			mount.get_node("ControlNodes").show()
			mount.get_node("Weapon/ControlNodes").show()

func hideAllControlNodes():
	if not isPlayer:
		if has_node("ControlNodes"):
			has_ControlNodes = false
			$ControlNodes.visible = false
		for mount in $Mounts.get_children():
			mount.get_node("ControlNodes").hide()
			mount.get_node("Weapon/ControlNodes").hide()
	
func unload_gear():
	for n in items:
		n.doUnload()
	
func getSelfSpawnPosition(viewFrom, viewTo):
#	print("getSpawnPos Base")
#	print(viewFrom, viewTo)
	var x = getSpawnX(viewFrom, viewTo)
	var y = getSpawnY(viewFrom, viewTo)
	return Vector2(x, y)
	
func getSpawnX(viewFrom, viewTo):
	var xRng = Globals.rng.randi_range(100, 600)
	var dir = Globals.getRandomEntry([-1, 1])
	var x = 0
	if dir == -1:
		x = viewFrom.x - xRng
	else: x = viewTo.x + xRng
	x = clamp(x, 300, Globals.WIDTH-300)
	return x
	
func getSpawnY(_viewFrom, _viewTo):
	var variance = 400
	var y = Globals.HEIGHT/2 + Globals.rng.randi_range(-variance, variance)
	return y

func setTargetx():
	print("setTargetx, context: ", self.display, " #", id)
	var targetgroup = "friendly"
	if is_in_group("friendly"):
		targetgroup = "hostile"
	
	var allTargets = get_tree().get_nodes_in_group(targetgroup)
	var opttargets = Array()
	for n in allTargets:
		if not n.isLegalTarget(): continue
		var dist = global_position.distance_to(n.global_position)
		#print("dist to ", n.display, ": ", int(dist))
		if dist < sightRange:
			opttargets.append(n)
		
	if len(opttargets):
		curTarget = Globals.getRandomEntry(opttargets)
	else: curTarget = null
	
	print("setting target for ", self.display, " to ", curTarget.display)

func setDirection(dirVector:Vector2 = Vector2.ZERO):
	if dirVector:
		direction = dirVector
	else:
		direction = Vector2(Globals.getRandomEntry([-1, 1]), 0)
	
	if direction == Vector2(-1, 0):
		direction *= -1
		doTurnaround()
		
	#print(self.display, " set dir to ", direction)
	
func doTurnaround():
#	print(self.display, " #", id, ": doTurnaround")
	direction *= -1
	$Sprites/Main.flip_h = !$Sprites/Main.flip_h
	mirrorTurrets()
	mirrorThrusters()
	mirrorVarious()
	mirrorColNodes()

func mirrorTurrets():
	for n in $Mounts.get_children():
		n.position.x *= -1
#		if not n.has_node("Weapon"): return
		var weapon = n.get_node("Weapon")
		weapon.anchor.x *= -1
		weapon.current_rot.x *= -1
		weapon.rotation = weapon.current_rot.angle()
		n.get_node("DebugAim/Start").scale.x *= -1
		n.get_node("DebugAim/End").scale.x *= -1
		
func mirrorThrusters():
	for n in $ThrusterNodes.get_children():
		n.position.x *= -1
		if n.rotation == 0:
			n.get_node("Particle2D").process_material.initial_velocity *= -1
		
func toggleThrusters():
	for n in $ThrusterNodes.get_children():
		n.visible = !n.visible
		
func mirrorVarious():
	for node in $EffectNodes.get_children():
		node.position.x *= -1

func mirrorColNodes():
	if $Sprites/Main.flip_h == true:
		$ColNodes.rotation = -(2*rotation)
	else: $ColNodes.rotation = 0

func setArmament():
#	print("setArmament")
	var index = 0
	for mount in $Mounts.get_children():
		mount.setFaction(faction)
		mount.do_init()
		var weapon = getPossibleWeapons(index)
		index += 1
#		if !weapon:
#			continue
		addWeapon(weapon, mount)
		
	addStartingItems()
	
func addWeapon(weapon, mount):
	if not weapon:
		return
	mount.add_child(weapon)
	weapon.setFaction(faction)
	weapon.anchor = Vector2.RIGHT.rotated(deg2rad(mount.startAngle))
	weapon.current_rot = weapon.anchor
	weapon.rotation = weapon.current_rot.angle()
	weapon.maximum_rotation = deg2rad(mount.maximum_rotation)
	weapon.turnrate = deg2rad(mount.turnrate)
	weapon.faction = faction
	weapon.set_owner(mount)
	if mount.turnrate == 0 or mount.maximum_rotation == 0:
		weapon.canRotate = false
	weapon.shooter = self
	
	weapon.check_init_aimdebug()
	
func addStartingItems():
	pass
	
func getPossibleWeapons(_index):
	return
	
func _on_support_duration_timeout(timer):
	print("_on_support_duration_timeout")
	timer.stop()
	warpOutStepOne()

func getDummyTarget(xa, xb, ya, yb):
	#var x = Globals.getRandomEntry([-1, 1])
	var x = Globals.getRandomEntry([xa, xb])
	var y = Globals.getRandomEntry([ya, yb])
	var angle = Globals.rng.randi_range(-10, 10)
	var dist = self.speed * 3
	var vector = Vector2(x, y).rotated(deg2rad(angle)) * dist
	var targetPos = global_position + vector
	
	var tresh = 250
	
	if targetPos.y < tresh:
		targetPos.y = tresh*2
	elif targetPos.y > Globals.HEIGHT - tresh:
		targetPos.y = Globals.HEIGHT - tresh*2
	
	if targetPos.x < tresh:
		targetPos.x = tresh*2
	elif targetPos.x > Globals.WIDTH - tresh:
		targetPos.x = Globals.WIDTH - tresh*2
	
	curTarget = Globals.DUMMY.instance()
	curTarget.position = targetPos
	Globals.curScene.add_child(curTarget)
	return curTarget
	
func checkAggro(shooterObj):
	if not shooterObj: return
#	print("shot by: ", shooter.display, " #", shooter.id)
#	print("my target is: ", target.display, " #", target.id)
#	print(shooter.display)
#	print(self.display)
	if curTarget == null: #and shooter.id != target.id:
		#print("aggroed")
		curTarget = shooterObj

func createResources():
	var perInstance = 1
	var total = self.lootValue / perInstance
	for n in total:
		var reward = Globals.REWARD.instance()
		Globals.curScene.get_node("Various").add_child(reward)
		reward.position = global_position + Vector2(Globals.rng.randi_range(-texDim.x/2, texDim.x/2), Globals.rng.randi_range(-texDim.y/2, texDim.y/2))
		reward.rotation_degrees = Globals.rng.randi_range(0, 359)
		reward.velocity = Vector2(500, 0).rotated(reward.rotation)
		reward.resValue = perInstance
		reward.curTarget = player
	#queue_free()
	
func setFriendly():
	.setFriendly()
	if is_in_group("hostile"):
		remove_from_group("hostile")
	add_to_group("friendly")
	
func setHostile():
	.setHostile()
	if is_in_group("friendly"):
		remove_from_group("friendly")
	add_to_group("hostile")
	
func setNeutral():
	.setNeutral()
	if is_in_group("hostile"):
		remove_from_group("hostile")
	if is_in_group("friendly"):
		remove_from_group("friendly")

func add_primary_target(primTarget):
	print("add_primary_target on ", self.display, " #", id, ": target ", primTarget.display, " #", primTarget.id)
	targetsArr.append({"target": primTarget, "prio": 0})
	return
	
func setWrecked():
	health = Globals.rng.randi_range(ceil(maxHealth*0.1), ceil(maxHealth * 0.3))
	destroyed = true
	for n in $Mounts.get_children():
		n.kill()
#
func killByCrash():
	return
	
func get_class():
	return str("Unit_Base")
	
func isLegalTarget():
	if destroyed or not ready or indestructable:
		return false
	return true
	
func applyForce(force):
#	print("applying force on ", self.display, ": ", force/mass)
	extForces += force/mass
	
func remove_cur_target_set_new_target():
#	print(self.display, ": remove_cur_target_set_new_target()")
	remove_cur_target()
	set_new_target()

func remove_cur_target():
#	print("remove_cur_target from ", self.display, " #", get_instance_id())
	for n in targetsArr:
		if curTarget == n.target:
			targetsArr.erase(n)
			curTarget = null
			if forcedLock:
				forcedLock = false
			break
	for n in $Mounts.get_children():
#		if n.has_node("Weapon"):
		var w = n.get_node("Weapon")
		w.curTarget = null
		if w.forcedLock:
			w.forcedLock = false

func set_new_target():
#	print("set_new_target on ", self.display, " #", get_instance_id())
	
	if not targetsArr.size():
		state_m.set_state(state_m.states.wander)
#		print("no targets!")
		return
	
	var prio:int = 10
	var curPrio:int = 0
	var changed:bool = false
	
	if curTarget != null:
		for n in targetsArr:
			if curTarget == n.target:
				curPrio = n.prio
				
		for n in targetsArr:
			if n.prio < curPrio and n.prio < prio:
				changed = true
				curTarget = n.target
				prio = n.prio
	else:
		changed = true
		for n in targetsArr:
			if n.prio < prio:
				curTarget = n.target
				prio = n.prio
#				print("targeting: ", curTarget.display, " #", curTarget.get_instance_id())

	if changed:
		state_m.set_state(state_m.states.close)
	
func is_legal_target(target_unit):
	return true

func _on_Sight_area_entered(area):
#	print(self.display, ", target: ", area.owner.display, " has LEFT sight !")
	if area.owner.isObstacle or self == area.owner or self.faction == area.owner.faction:
		return
	for n in targetsArr:
		if n.target == area.owner:
			return
#	print(self.display, ": adding ", area.owner.display, " to targets")
	if is_legal_target(area.owner):
		targetsArr.append({"target": area.owner, "prio": 1})
	set_new_target()

func _on_Sight_area_exited(area):
#	print(self.display, ", target: ", area.owner.display, " has ENTERED sight !")
	for n in targetsArr:
		if area.owner == n.target:
			if n.prio != 0:
#				print("deleting from targets")
				targetsArr.erase(n)
			return
			
func _on_AggroLeave_area_exited(area):
	var index = -1
	for n in targetsArr:
		index += 1
		if n == area.owner:
			break
	
	if index > -1:
		targetsArr.erase(area.owner)
		
func doUnselectWeapons():
	return "ERROR doUnselectWeapons"
	
func disableItemsAndWeapons():
	return "ERROR disableItemsAndWeapons"	
	
func enableWeapons():
	for n in $Mounts.get_children():
		n.get_node("Weapon").doEnable()
#	getActiveWeapon().doSelect()

func disableWeapons():
	for n in $Mounts.get_children():
		n.get_node("Weapon").doDisable()

func enableItems():
	if Globals.curScene.get_class() != "Intermission":
		for n in $Items.get_children():
			n.doEnable()
			n.doReset()

func disableItems():
	for n in $Items.get_children():
		n.doDisable()
	
func getActiveWeapon():
	return "ERROR getActiveWeapon"

func getDangerValue():
	return 3.0

func initSteering():
	interest.resize(num_rays)
	danger.resize(num_rays)
	ray_directions.resize(num_rays)
	ray_degree.resize(num_rays)
	for i in num_rays:
		var angle = i * 2 * PI / num_rays
		ray_directions[i] = Vector2.RIGHT.rotated(angle)
		ray_degree[i] = rad2deg(angle)
		
		if $Debug.visible:
			var line = Line2D.new()
			line.name = str(i)
			line.width = 3
			line.default_color = Color(0, 0, 0, 1)
			line.add_point(Vector2.ZERO)
			line.add_point(Vector2.RIGHT.rotated(angle) * look_ahead)
			line.name = str("steer_choice", i)
			$Debug/steering_choice.add_child(line)

func set_interest():
	if moveTarget:
		var path_direction: Vector2 = (moveTarget - global_position).normalized()
		for i in num_rays:
			var d = ray_directions[i].rotated(rotation).dot(path_direction)
			interest[i] = max(0, d)
	else:
		set_default_interest()
		
func set_default_interest():
	for i in num_rays:
#		var d = ray_directions[i].rotated(rotation).dot(transform.x)
		interest[i] = 0

func set_danger():
	if $SM.state != $SM.states.crash: 
		var space_state = get_world_2d().direct_space_state
		for i in num_rays:
			var cast = space_state.intersect_ray(
				position,
				position + ray_directions[i].rotated(rotation) * look_ahead, [self], 0b10000, false, true
			)
			if cast:
				danger[i] = getDangerValueFromEntity(cast.collider.owner.display)
				if danger[i] == null:
	#				print("NULL VALUE ", self.display, " raycast into ", cast.collider.owner.display)
					danger[i] = 0.0
			else:
				danger[i] = 0.0

func choose_direction():
	dir_update_frames -= 1
	if dir_update_frames > 0:
		return
	
	dir_update_frames = 12
		
	for i in num_rays:
		if danger[i] > 0.0:
			interest[i] -= danger[i]
		
	if $Debug.visible:
		for i in num_rays:
			$Debug/steering_choice.get_child(i).default_color = Color(0, 0, 0, 1)
			if danger[i] > 0.0:
				$Debug/steering_choice.get_child(i).default_color = Color(1, 0, 0, 1)
			$Debug/steering_choice.get_child(i).points[1] = ray_directions[i] * look_ahead * interest[i]
		
	chosen_dir = Vector2.ZERO
	for i in num_rays:
		chosen_dir += ray_directions[i] * interest[i]
	chosen_dir = chosen_dir.normalized()
	
func getDangerValueFromEntity(targetDisplay):
	if targetDisplay in avoidValues:
		return avoidValues[targetDisplay]
	return 0.0
	
func getFuturePosition(time):
	return global_position + velocity * time
	
func disableBoosting():
	return
	
func disableAllThrusterParticles():
	disableBoosting()
	for n in $ThrusterNodes.get_children():
		n.get_node("Particle2D").emitting = false

func enableAllThrusterParticles():
	for n in $ThrusterNodes.get_children():
		n.get_node("Particle2D").emitting = true
	$ThrusterNodes/Aft_Boost/Particle2D.emitting = false

func hasNoTargetSet():
	if curTarget == null or not is_instance_valid(curTarget) or curTarget.destroyed or curTarget.ready == false:
		return true
	return false

func _on_target_hasWarpedOut(target):
	print(self.display, ": my target has warped out")
	for n in targetsArr:
		if n.target == target:
			targetsArr.erase(n)
	set_new_target()
	
	if rand_range(0, 1) > 5:
		setupDelayedWarpOut(2.0)

func initAsAttacker():
	$SM.set_state($SM.states.close)

func get_item(string):
	for n in $Items.get_children():
		if n.display == string:
			return n	
	
func updateStats():
	return
	
func addItem(item):
	item.faction = faction
	item.position = Vector2(0, 0)
	$Items.add_child(item)
	item.set_owner(self)
	items.append(item)
	if item.needsTarget():
		item.setItemTarget(self)
	item.doInit()
	item.makeUntargetable()
	item.makeInvisible()
	updateStats()
	
	if isPlayer:
		item.doInitUI()
		addItemToUI(item)
	
func addItemToUI(item):
	return false

func add_health_bar():
	.add_health_bar()
	healthbar.offset.y = texDim.y * 0.8 + 20
	
func enterBoundary():
	toching_bound = true
	gravity_vec = Vector2.ZERO
	
func exitBoundary():
	toching_bound = false
	gravity_vec = Globals.BASEGRAVITY
