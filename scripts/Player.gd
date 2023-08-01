extends Base_Unit

onready var ui = Globals.curScene.get_node("UI")

var frame = 0

var display = "Player"

var aItem:int = -1
var items = Array()

var baseHealth:int
var healthRegenTime:float
var baseShield:int
var baseShieldRegenTime:float
var baseShieldBreakTime:float
var enginePower:int
var friction:float
var agility:float
var boostCharge:int
var boostMaxCharge:int
var boostPower:int

var isBoosting = false

var shieldRegenTime:float
var shieldBreakTime:float

var ressources = 0

var new:bool = true

var weapon
signal updatePlayerHP
signal updatePlayerRes
signal updateShieldCooldown

var thrusters =  Array()

var baseStats

var mouseDown = false

var ticksShieldBreakTimer = 0
var ticksSinceGroundDamage = 0


func _ready():
	#print("ready ship")
	texDim = Vector2($Sprite.texture.get_width() * $Sprite.scale.x, $Sprite.texture.get_height() * $Sprite.scale.y)
	isPlayer = true
	setFriendly()
	setBaseStats()
	#addKeyForItem()
	health = baseHealth
#	maxSpeed = 350
	
		
#var groceries = {"Orange": 20, "Apple": 2, "Banana": 4}
#for fruit in groceries:
#	var amount = groceries[fruit]

func setBaseStats():
#	Globals.BASEGRAVITY = Vector2(0, 0)
	var stats = {
		"baseHealth": 30,
		"healthRegenTime": 0.0,
		"baseShield": 30,
		"baseShieldRegenTime": 1.0,
		"baseShieldBreakTime": 4.0,
		"enginePower": 350,
		"maxSpeed": 500,
		"friction": 0.011,
#		"agility": 0.05,
		"agility": 4.5,
		"boostCharge": 60,
		"boostMaxCharge": 60,
		"boostPower": 800,
	}
	
	baseStats = stats
	for stat in stats:
		self[stat] = stats[stat]
		
	coreRange = 75

func doInit():
	visible = false
	shield = 0
	updateStats()
#	weapons[0].toggle()
	ui.get_node("Bars/Panel/Shield/Value").text = str(shield, " / ", maxShield)
	$ShieldBreak.wait_time = shieldBreakTime
	$ShieldRegen.wait_time = shieldRegenTime
	
	if not is_connected("hasWarpedOut", Globals, "doAdvanceLevel"):
		connect("hasWarpedOut", Globals, "doAdvanceLevel")
		
	$Label.set_as_toplevel(true)

	addPhysCollision()
	addSightCollision()

func exitLevel():
	for item in items:
		item.addCharge()
		
#	player.connect("hasWarpedIn", self, "missionStart")
	if is_connected("hasWarpedIn", Globals.handler_mission, "missionStart"):
		disconnect("hasWarpedIn", Globals.handler_mission, "missionStart")
		print("is connected")

func addRessources(val):
	ressources += val
	emit_signal("updatePlayerRes", ressources)
	
func setInactive():
	set_physics_process(false)
	$Mounts.visible = false
	$Weapons.visible = false

func setActive():
	set_physics_process(true)
	updateShield()
	$Mounts.visible = true
	$Weapons.visible = true
	
func doSelectItem(key):
	#if aItem == key: return
	#else:
	var hits = -1
	var index = -1
	for item in items:
		index += 1
		if item.type == 0:
			hits += 1
			if hits == key:
				items[aItem].toggle()
				aItem = index
				items[aItem].toggle()
				return

func selectWeapon(step):
	if not weapons[aWeapon].canToggle(): return
	weapons[aWeapon].toggle()
	aWeapon += step
	
	if aWeapon > len(weapons)-1:
		aWeapon = 0
	elif aWeapon < 0:
		aWeapon = len(weapons)-1

	weapons[aWeapon].toggle()
	#emit_signal("weaponToggle", getActiveWeapon())
	
func getActiveWeapon():
	return weapons[aWeapon]
	
func getActiveItem():
	if aItem >= 0: return items[aItem]
	return false

func doPrintFacing():
	var facing = self.rotation_degrees;
	var lookAt = rad2deg(Globals.mouse.angle_to_point(position))
	var dif = lookAt - facing
	
	print("facing: ", facing)
	print("lookAt: ", lookAt)
	print("dif: ", dif)
	
func on_damage_taken():
	emit_signal("updatePlayerHP", health, maxHealth, shield, maxShield)
	
func handleShieldDamagxe(shieldDmgTaken, pos, angle):
	addShieldExplosion(shieldDmgTaken, pos, angle)
	var offset = Vector2(Globals.rng.randi_range(-15, 15), Globals.rng.randi_range(-20, -40))
	createFloatingLabel(shieldDmgTaken, global_position + offset, Vector2(0, -100), Color(0, 0, 1, 1))
	updateShield()
	checkForTriggers("on_shield_damage")
	if shield <= 0:
		call_deferred("unpowerShield")

func handleHullDamagex(remDmg, pos, angle):
	addHitExplosion(remDmg, pos, angle)
	var offset = Vector2(Globals.rng.randi_range(-15, 15), Globals.rng.randi_range(-20, -40))
	createFloatingLabel(remDmg, global_position + offset, Vector2(0, -100), Color(1, 0, 0, 1))
	checkForTriggers("on_damage")
	
	var trauma = remDmg/25.0
	Globals.curScene.get_node("CamA").add_trauma(trauma)

func get_class():
	return "Player"
	
func checkForTriggers(condition):
	#print("checkForTriggers ", get_class())
	for item in items:
		if item.trigger == condition:
			item.call_deferred("doUse")
		
func unpowerShield():
	$ShieldPos/ShieldSprite.show()
	$ShieldPos/ShieldSprite.scale = Vector2(0.5, 0.5)
	$ShieldPos/ShieldSprite.modulate.a = 1
	
	var dur = 0.5
	
	$Tween.interpolate_property($ShieldPos/ShieldSprite, "modulate:a",
		1.0, 0.0, dur,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	
	$Tween.interpolate_property($ShieldPos/ShieldSprite, "scale",
		Vector2(0.5, 0.5), Vector2(2, 2), dur,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	
	$ShieldRegen.stop()
	$ShieldBreak.start()
	ticksShieldBreakTimer = 1
	checkForTriggers("on_shieldbreak")
	handleShieldCooldownStuff()
	
func powerShield():
#	print("powerShield")
	shield = 0
	$ShieldRegen.wait_time = 0.05
	$ShieldRegen.start()
	
	$Tween.interpolate_property($ShieldPos/ShieldSprite, "modulate:a",
		0.4, 0.8, 1.0,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	
	$Tween.interpolate_property($ShieldPos/ShieldSprite, "scale",
		Vector2(2.5, 2.5), Vector2(0.5, 0.5), 1.0,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	
	yield($Tween, "tween_all_completed")
	#shield = floor(maxShield/3)-1
	#print("tween_all_completed")
	$ShieldRegen.wait_time = shieldRegenTime
	$ShieldRegen.start()
	#updateShield()
	#_on_ShieldRegen_timeout()

func handleShieldCooldownStuff():
	ticksShieldBreakTimer += 1
	if ticksShieldBreakTimer == 4:
		ticksShieldBreakTimer = 1
		emit_signal("updateShieldCooldown", round(($ShieldBreak.time_left)*10)/10)
		
func _on_ShieldRegen_timeout():
	#print("_on_ShieldRegen_timeout")
	#print("shield +1")
	shield = min(maxShield, shield + 1)
	updateShield()
	
func _on_ShieldBreak_timeout():
	ticksShieldBreakTimer = 0
	$ShieldBreak.stop()
	powerShield()
	
func updateShield():
	var factor:float = float(shield) / maxShield  # 27 / 30
	$ShieldPos/ShieldSprite.modulate.a = factor
	emit_signal("updatePlayerHP", health, maxHealth, shield, maxShield)
	#update()
	if ready and shield > 0 and shield < maxShield:
		$ShieldRegen.start()
	
#	$ShieldPos/Node2D.maxShield = maxShield
#	$ShieldPos/Node2D.ratio = factor
#	$ShieldPos/Node2D.update()

func canWarpOut():
	if ready and not isWarping:
		return true
		if Globals.handler_mission != null and Globals.handler_mission.isMissionCompleted():
			return true
		elif Globals.handler_mission == null:
			return true
	return false

func get_input(_delta):
	
	if Input.is_action_pressed("ui_select"):
		if canWarpOut():
			Globals.handler_mission.missionState = 0
			doWarpOut()
			
	if Input.is_action_just_pressed("alt_use_item"):
		if aItem >= 0: getActiveItem().doUse()
		
	if Input.is_action_pressed("fire"):
		mouseDown = true
#		
		if weapons[aWeapon].canFire():
			weapons[aWeapon].doFire(null)
		
	if Input.is_action_just_released("fire"):
		mouseDown = false
		#weapons[aWeapon].stopFiring()
#		print("release")

		
	if Input.is_action_just_pressed("right_click"):
		pass
		
		
	var input = Vector2.ZERO
	
	if Input.is_action_pressed("hold_shift"):
		accel = Vector2.ZERO
		velocity = Vector2.ZERO
		extForces = Vector2.ZERO
		
		return Vector2.ZERO 
	
	$ThrusterNodes/Front_A.visible = 0
	$ThrusterNodes/Front_B.visible = 0
	$ThrusterNodes/Port.visible = 0
	$ThrusterNodes/Starboard.visible = 0
	
		
	if Input.is_action_pressed("270"):
#		input += Vector2(0, -1)
		$ThrusterNodes/Port.visible = 1
	if Input.is_action_pressed("90"):
#		input += Vector2(0, 1)
		$ThrusterNodes/Starboard.visible = 1
	if Input.is_action_pressed("180"):
#		input += Vector2(-1, 0)
		$ThrusterNodes/Front_A.visible = 1
		$ThrusterNodes/Front_B.visible = 1
	if Input.is_action_pressed("0"):
#		input += Vector2(1, 0)
		$ThrusterNodes/Aft_A.emitting = true
		$ThrusterNodes/Aft_B.emitting = true
		if not isBoosting and boostCharge > 0:
			isBoosting = true
			$ThrusterNodes/Aft_Boost.emitting = true
		elif isBoosting and boostCharge == 0:
			isBoosting = false
			$ThrusterNodes/Aft_Boost.emitting = false
	elif not Input.is_action_pressed("0"):
		if isBoosting:
			isBoosting = false
			$ThrusterNodes/Aft_Boost.emitting = false
		boostCharge = min(boostMaxCharge, boostCharge +1)
		$ThrusterNodes/Aft_A.emitting = false
		$ThrusterNodes/Aft_B.emitting = false
		
#	print("boosting ", isBoosting)
	#print(thrusters)
	return Input.get_vector("180","0","270","90")
#	return Input.get_vector("90","180","0","270")
#	return input
	
#func _physics_process(delta):
func handleAimRectangle(delta):
#	print("handleAimRectangle player")

	var angle:int = getActiveWeapon().deviation
	
	var targetUp = Vector2.ZERO
	var targetDown = Vector2.ZERO
	
	var close = 200
	targetUp = Vector2(close, 0).rotated(deg2rad(angle))
	targetDown = Vector2(close, 0).rotated(deg2rad(-angle))
	$"Mounts/1/AimClose".points[0] = targetUp
	$"Mounts/1/AimClose".points[1] = targetDown
	
	var mid = 450
	targetUp = Vector2(mid, 0).rotated(deg2rad(angle))
	targetDown = Vector2(mid, 0).rotated(deg2rad(-angle))
	$"Mounts/1/AimMid".points[0] = targetUp
	$"Mounts/1/AimMid".points[1] = targetDown
	
func xhandleAngularRotation(delta):
	var mouse_pos = get_global_mouse_position()
	var object_pos = global_position
	
	var direction = (mouse_pos - object_pos).normalized()
	var target_angle = atan2(direction.y, direction.x)
	
	var current_angle = rotation
	var angle_diff = target_angle - current_angle
	
	current_angle += wrapf(angle_diff, -PI, PI) * delta * agility
	
	set_rotation(current_angle)

func wrapf(value, min_value, max_value):
	var ran = max_value - min_value
	return min_value + fmod(fmod(value - min_value, ran) + ran, ran)
	
	
	
	
	

func handleAngularRotation(_delta):
	
#	var old = rotation_degrees
#
#	rotation = lerp_angle(rotation, (Globals.MOUSE - global_position).angle(), agility/50)
#
#	print()
#	print(Engine.get_idle_frames())
#	print(rotation_degrees)
#
#	return

	var amount_to_turn = agility * _delta  # or whatever
	var forwardV = Vector2(cos(rotation), sin(rotation))
#	var omega = forwardV.angle_to((Globals.MOUSE - global_position))
#	var change
	
	rotation = forwardV.move_toward((Globals.MOUSE - global_position), _delta * agility).angle()
#	var new = rotation_degrees
#
#
#	print(new-old)
	return
#
#	if abs(omega) <= amount_to_turn:
#	  change = 0
#	else:
#	  change = amount_to_turn * sign(omega)
#
#	print(rad2deg(change))
#	rotation += change
#	return
#

#
#	#var mousePos = get_global_mouse_position()
#	var forwardV = Vector2(cos(rotation), sin(rotation))
#	var omega = (forwardV.angle_to((Globals.MOUSE - global_position)))
##	if abs(omega) < 0.02: return
#
#	print(global_rotation_degrees)
#	print(global_position)
#	print(Globals.MOUSE)
#	print(omega)
##	if omega > 0:
##		omega = max(omega, 0.1)
##	else: omega = min(-0.1, omega)
#
#	var change = sign(omega) * _delta
#	rotation += change
#
func processMovement(_delta):
#	print("playewr processmove")
#	print(Engine.get_idle_frames())
	handleAngularRotation(_delta)
	handleAimRectangle(_delta)
	if ticksShieldBreakTimer > 0:
		handleShieldCooldownStuff()
	
#	print("boosting: ", isBoosting)
	
#	var dir = Input.get_vector("270","90","180","0")
	
	var direction = get_input(_delta)#.rotated(rotation)
	
	var sideBoost = 4
	var sideBoosting = false
#	print(directionw)
	if direction:
		var thrust = (direction * enginePower/20)
		if thrust.y != 0:
			sideBoosting = true
			thrust.y *= sideBoost
		if isBoosting and boostCharge:
			thrust.x *= boostPower
			boostCharge -= 1
#		print(thrust.x)
		
		thrust = thrust.rotated(rotation)
		accel += thrust
		if isBoosting:
			accel = accel.limit_length(enginePower + boostPower)
		else:
			accel = accel.limit_length(enginePower + 300 if sideBoosting else enginePower)
		gravity_vec = Vector2.ZERO
	else:
		accel = Vector2.ZERO
		gravity_vec = Globals.BASEGRAVITY
	
		
	velocity = lerp(velocity, Vector2.ZERO, friction)
	velocity += accel * _delta
#	velocity = velocity.limit_length(maxSpeed)
	velocity += gravity_vec * _delta
	
	position += velocity * _delta
	position += extForces * _delta
#	print(position)

	if extForces:
		print(extForces)
	
	isPlayerOutOfBounds()
	
	
func processMovement2(_delta):
#	print("processMovement")
#	handleAngularRoätation(_delta)
	
	var direction = get_input(_delta)#.rotated(rotation)
	if direction.length() > 0:
		accel = direction.normalized() * enginePower
		
		gravity_vec = Vector2.ZERO
		if isBoosting and boostCharge:
			accel.x += boostPower
			boostCharge -= 1
	else:
		accel = Vector2.ZERO
		velocity = lerp(velocity, Vector2.ZERO, friction)
		gravity_vec = Globals.BASEGRAVITY
	
	accel = accel.rotated(rotation)
	velocity += accel * _delta
	velocity = velocity.limit_length(maxSpeed)
	velocity += gravity_vec
	
	position += velocity * _delta
	position += extForces * _delta
	
	isPlayerOutOfBounds()
#
#func _draw():
#	if ready and shield > 0 and ticksShieldBreakTimer == 0 and not isWarping:
#		$ShieldPos/Node2D.ratio = float(shield)/maxShield
#		$ShieldPos/Node2D._draw()
	
func isPlayerOutOfBounds():
#	print("isPlayerOutOfBounds")
	position.x = clamp(position.x, 5, Globals.WIDTH -5)
	position.y = clamp(position.y, 5, Globals.HEIGHT -5)
		
	if position.y > Globals.MUDY - 30 and accel.length():
		var smoke = Globals.SMOKE_GROUND.instance()
		Globals.curScene.get_node("Various").add_child(smoke)
		smoke.position = position
		smoke.emitting = true

	if position.y > Globals.MUDY:
		if ticksSinceGroundDamage == 60:
			print("GROUND DMG")
			return
			ticksSinceGroundDamage = 0
			
			var proc = Globals.BULLET_RED.instance()
			Globals.curScene.get_node("Refs").add_child(proc)
		#func construct(init_dmgType, init_speed, init_minDmg, init_maxDmg, init_impactForce, init_faction, init_projSize, init_projNumber = 1, init_shooter = false):
			proc.construct(0, 125, 10, 10, Vector2.ZERO, faction, 1)
#			proc.set_physics_process(false)
#			proc.disableCollisionNodes()
	
#	func construct(init_type:int, init_display:String
			takeDamage(proc, 1)
			proc.postImpacting()
		else: ticksSinceGroundDamage += 1
	else: ticksSinceGroundDamage = 0	
	
func doInitGear():
	for n in items:
		n.doInit()
		n.set_physics_process(true)

func addItem(item):
	$Items.add_child(item)
	items.append(item)
	if item.needsTarget():
		item.setItemTarget(self)
	item.doInitUI()
	item.position = Vector2(0, 0)
	item.makeUntargetable()
	item.makeInvisible()
#	item.UI_node = item.getItemIconContainer()
#	item.getStatsPanel()
#	item.set_physics_process(true)
#	item.statsPanel.show()
	updateStats()
	
	if item.type == 0: #actives
		item.full_ui_box.get_node("Vbox").remove_child(item.UI_node)
		item.full_ui_box.get_node("Vbox").remove_child(item.subPanel_Stats)
		ui.get_node("Place/Bottomleft/ItemsActive/HB").add_child(item.UI_node)
		ui.get_node("Place/BottomleftHigher").add_child(item.subPanel_Stats)
		item.subPanel_Stats.hide()
#		item.statsPanel.hide()
		if aItem == -1:
			for n in items:
				aItem += 1
				if item.id == n.id:
					#aItem = len(items)-1
					items[aItem].toggle()
					break
	elif item.type == 1: #stats
		item.full_ui_box.get_node("Vbox").grow_horizontal = 1
		item.full_ui_box.get_node("Vbox").grow_vertical = 1
		if item.full_ui_box.is_inside_tree():
			ui.get_node("LootNodes").remove_child(item.full_ui_box)
		ui.get_node("Pause/MC/VBC/HBC/PC/VBC/HBC").add_child(item.full_ui_box)
		item.subPanel_Stats.show()
	elif item.type == 2: #assive actives
		item.full_ui_box.get_node("Vbox").grow_horizontal = 1
		item.full_ui_box.get_node("Vbox").grow_vertical = 1
		if item.full_ui_box.is_inside_tree():
			ui.get_node("LootNodes").remove_child(item.full_ui_box)
		ui.get_node("Pause/MC/VBC/HBC/PC/VBC/HBC").add_child(item.full_ui_box)
		item.subPanel_Stats.show()
		
func addWeapon(weapon):
	$Weapons.add_child(weapon)
	weapon.active = false
	weapons.append(weapon)
	weapon.get_node("Aim").queue_free()
	weapon.shooter = self
	weapon.faction = faction
	weapon.makeInvisible()
	weapon.position = Vector2(0, 0)
#	weapon.statsPanel.rect_position = Vector2(0, 0)
#	weapon.statsPanel.hide()
	weapon.doInitUI()
	
#	Globals.curScene.get_node("UI/Place/Topleft/WeaponsOverview/VB").add_child(weapon.UI_node)

	weapon.full_ui_box.get_node("Vbox").remove_child(weapon.UI_node)
	weapon.full_ui_box.get_node("Vbox").remove_child(weapon.subPanel_Stats)
	Globals.curScene.get_node("UI/Place/Topleft/WeaponsOverview/VB").add_child(weapon.UI_node)
	Globals.curScene.get_node("UI/Place/TopleftLower/WeaponStatsPos").add_child(weapon.subPanel_Stats)
	weapon.subPanel_Stats.hide()
		
func addStartingWeapons():
	addWeapon(Globals.getSpecificBaseWeaponByName("Autocannon"))
	addWeapon(Globals.getSpecificBaseWeaponByName("Hvy Autocannon"))
	addWeapon(Globals.getSpecificBaseWeaponByName("Expl. Autocannon"))
#	addWeapon(Globals.getSpecificBaseWeaponByName("Missilelauncher"))
#	addWeapon(Globals.getSpecificBaseWeaponByName("Laserlance"))
	
func addStartingItems():
#	addItem(Globals.getItemByName("Counterbarrage System"))
	addItem(Globals.getItemByName("Orbital Strike (Arty)"))
#	addItem(Globals.getItemByName("Conv. Bomb Rack"))
#	addItem(Globals.getItemByName("Missile Pod"))
#	addItem(Globals.getItemByName("Conv. Bomb Rack"))
#	addItem(Globals.getItemByName("Hail Support: Frigate"))
#	addItem(Globals.getItemByName("Health UP Shield DOWN"))
	
	

#	get = "Health+Shield+"
#	get = "Orbital Strike (Beam)"
#	get = "Orbital Strike (Arty)"
#	get = "Hail Support: Fighter"
#	item = Globals.getItemByName(get)
#	item.quality = 2
#	item.initQuality()
#	addItem(item)

func isLegalTarget():
	return true

func updateStats():
#	print("updateStats")
	setBaseStats()
	#health = baseHealth
	maxHealth = baseHealth
	#shield = baseShield
	maxShield = baseShield
	shieldRegenTime = baseShieldRegenTime
	shieldBreakTime = baseShieldBreakTime
	
	for item in items:
		if item.trigger == "":
			for n in item.result:
				if "isStat" in n:
					if n.amount != 0:
						#print(entry)
						match n.modType:
							"flat":
								self[n.prop] += n.amount
							"pct":
								self[n.prop] *= n.amount

	$ShieldRegen.wait_time = shieldRegenTime
	$ShieldBreak.wait_time = shieldBreakTime
	 
	health = min(health, maxHealth)
	shield = min(shield, maxShield)
	
	ui.get_node("Bars/Panel/Shield").max_value = maxShield
	ui.get_node("Bars/Panel/Health").max_value = maxHealth
	
	updateShield()
	#$ShieldRegen.start()
	
func reInitItems():
	for n in player.items:
		n.doInit()

func checkAggro(shooterObj):
	return
	
func handleWeapons(_delta):
	return
	
func initAIList():
	return
	
func updateAIList():
	return
	
func updateDebugList():
	return
	
func handleControlNodes():
	return

func canBeOutOutBounds():
	return true

func initSteering():
	return

func setMass():
	mass = 2.0

func getRamDamasge():
	return false
	var ramBullet = Globals.BULLET_BLUE.instance()
	Globals.curScene.get_node("Refs").add_child(ramBullet)
	ramBullet.minDmg = 1
	ramBullet.maxDmg = 1
	ramBullet.impactForce = Vector2.ZERO
	return ramBullet
