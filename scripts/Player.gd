extends Base_Unit
class_name Player

onready var mainUI = Globals.curScene.get_node("UI")

var frame = 0

var display = "Player"

var aItem:int = -1

#var baseHealth:int
var healthRegenTime:float
var maxSideThrustDuration:float
#var enginePower:int
var friction:float
var agility:float
var boostCharge:float
var boostMaxCharge:float
var boostRegenTime:float
#var boostPower:int
var boostPower:float
var shiftDuration:float
var shiftCooldown:float

var sideThrust = false
var sideThrustDuration:float
var isRechargingBoost = false
var isShifting = false

var shieldRegenTime:float
var shieldBreakTime:float

var materials = 0

var new:bool = true

#var weapon
signal update_player_health
signal update_player_materials
signal updateShieldCooldown

var thrusters =  Array()

var baseStats

var mouseDown = false

var time_since_ground_dmg:float = 0.0
var time_since_ground_smoke:float = 0.0

#var boost_on:float = 0.0

func _ready():
	print("ready ship")
	texDim = Vector2($Sprites/Main.texture.get_width() * $Sprites/Main.scale.x, $Sprites/Main.texture.get_height() * $Sprites/Main.scale.y)
	isPlayer = true
	setFriendly()
#	setHostile()
	setBaseStats()
	#addKeyForItem()
	health = baseStats.maxHealth
	maxHealth = health
	gravity_vec = Globals.BASEGRAVITY
#	maxSpeed = 350
		
#	for n in weapons:
#		n.doDisable()
	
		
#var groceries = {"Orange": 20, "Apple": 2, "Banana": 4}
#for fruit in groceries:
#	var amount = groceries[fruit]

func setStats():
	pass

func setBaseStats():
	var stats = {
		"maxHealth": 30,
		"healthRegenTime": 0.0,
		"enginePower": 1600, #500dd
		"friction": 0.998, # 0.014
		"agility": 8.0,
		"boostCharge": 60,
		"boostMaxCharge": 60,
		"maxSideThrustDuration": 0.20,
		"boostRegenTime": 3.0,
		"boostPower": 1.5,
		"shiftDuration": 2.0,
		"shiftCooldown": 1.0,
		"shieldStats": {"maxShield": 30, "shieldRegenTime": 1.0, "shieldBreakTime": 4.0, "shieldFastCharge": 0.6, "shieldRadius": 30},
#		"shieldStats": {"maxShield": 10, "shieldRegenTime": 10.0, "shieldBreakTime": 40.0, "shieldFastCharge": 0.6, "shieldRadius": 30},
	}
	
	baseStats = stats
	for stat in stats:
		if stat in self:
			self[stat] = stats[stat]
		
	coreRange = 60
		
func process_movement(delta: float):
	var thrust_vector:Vector2 = Vector2.ZERO
	
	var back_weight: float = 0.5   # Counter-thrust is 30% power
	var side_weight: float = 0.5   # Side-thrust is 60% power
	var forward_weight: float = 1.0 # Forward is 100% power
	
	var drag_co:float = 1.5 # Higher = more "viscous" / snappy stops
	var boost_drag_co: float = 1.5 # Lower drag during boost = more sliding!
	var cur_max = enginePower / 2.0 # Baseline max speed
	
	# 1. Get raw input (-1 to 1)
	# W/S mapped to Y (negative is up/forward), A/D mapped to X
	var input_vec = get_input(delta)
	handleAngularRotation(input_vec, delta)

	# 2. Identify Local Directions
	var facing_dir = Vector2.RIGHT.rotated(rotation) # The "Forward" of your sprite
	var side_dir = facing_dir.rotated(PI/2)          # The "Right" of your sprite

	# 3. Calculate Thrust Force
	var thrust_force = Vector2.ZERO

	# W Key (Forward) - The "Aft Thruster"
	if input_vec.x > 0: 
		thrust_force += facing_dir * (enginePower * forward_weight)
	# S Key (Backward) - Retro Thrusters
	elif input_vec.x < 0:
		thrust_force -= facing_dir * (enginePower * back_weight)

	# A/D Keys (Strafing)
	if input_vec.y != 0:
		thrust_force += side_dir * (input_vec.y * enginePower * side_weight)

	# 4. Boost Logic (Modifies the Aft Thruster)
	var cur_drag = drag_co

	if aft_boosting:
		# Boost only applies if we are actually pushing Forward (W)
		if input_vec.x > 0:
			thrust_force *= boostPower
			cur_drag = boost_drag_co
			cur_max *= boostPower
			boostCharge = max(0, boostCharge - 60.0 * delta)
			
	# 5. Linear Drag & Physics
	# This is where the drift happens! Old velocity fights new thrust.
	var drag_vector = velocity * cur_drag
	var net_accel = thrust_force - drag_vector
	

	velocity += net_accel * delta
	# 6. Safety Clamp
	if velocity.length() > cur_max:
		velocity = velocity.limit_length(cur_max)
		
	if input_vec.x == 1:
		gravity_vec = Vector2.ZERO
	else:
		gravity_vec = Globals.BASEGRAVITY * 2.25
		
	mainUI.updateBoostChargeBar()

func doInit():
	visible = false
	updateStats()
	
	if not is_connected("hasWarpedOut", Globals.GAMESCREEN, "end_current_level"):
		connect("hasWarpedOut", Globals.GAMESCREEN, "end_current_level")
		
	$Label.set_as_toplevel(true)

	addPhysCollision()
#	addSightCollision()

func on_exit_level():
	for item in items:
		item.addCharge()
		
#	player.connect("hasWarpedIn", self, "missionStart")
	if is_connected("hasWarpedIn", Globals.handler_mission, "missionStart"):
		disconnect("hasWarpedIn", Globals.handler_mission, "missionStart")
		print("is connected")

func add_resources(val):
	materials += val
	emit_signal("update_player_materials", materials)
	
func setInactive():
	ready = false
	disableCollisionNodes()
	set_physics_process(false)
	disableItems()
	for n in $Mounts/A.get_children():
		n.doDisable()
	for n in $ThrusterNodes.get_children():
		disableThruster(n)
		
	$Mounts.visible = false

func setActive():
	ready = true
	enableCollisionNodes()
	set_physics_process(true)
	enableItems()
	enableShield()
	setFirstWeaponActive()
	getActiveWeapon().doSelect()
#	updateShield()
	$Mounts.visible = true
#	$Weapons.visible = true

func enableShield():
	$Mounts/A.get_child(0).doEnable()

func setFirstWeaponActive():
	var count = -1
	for wpn in $Mounts/A.get_children():
		count += 1
		if wpn.canBeSelected():
			aWeapon = count
			return
	
func doSelectItem(key):
	var hits = 0
	var index = -1
	for item in items:
		index += 1
		print(item.display)
		if item.type == 0:
			hits += 1
			if hits == key and aItem != index:
#				print("toggling!")
				items[aItem].toggle()
				aItem = index
				items[aItem].toggle()
				return
			elif hits == key and aItem == index:
				items[aItem].subPanel_Stats.showandfadeout()
#	print("no item to toggle foudn")

func selectWeapon(step):
	if not ready:
		return
	if not getActiveWeapon().canBeUnselected():
		return false
	
	getActiveWeapon().doUnselect()
		
	aWeapon += step
	if aWeapon > $Mounts/A.get_child_count()-1:
		aWeapon = 1
	elif aWeapon < 1:
		aWeapon = $Mounts/A.get_child_count()-1

	getActiveWeapon().doSelect()
	
func getActiveWeapon():
	return $Mounts/A.get_child(aWeapon)
	
func doUnselectWeapons():
	for n in $Mounts/A.get_children():
		n.doUnselect()
			
func disableItemsAndWeapons():
		print("error")
	
func enableWeapons():
	for n in $Mounts/A.get_children():
		n.doEnable()
	getActiveWeapon().doSelect()
	
func enableItems():
	for n in $Items.get_children():
		n.doEnable()
		
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
	emit_signal("update_player_health", health, maxHealth)

func get_class():
	return "Player"
	
func checkForTriggers(condition):
	#print("checkForTriggers ", get_class(ww))
	for item in items:
		if item.trigger == condition:
			item.call_deferred("doUse")
			#
func can_warp_in():
	return true
	
func can_warp_out():
#	print("can_warp_out")
	if isWarping: 
		return false
	if ready and not isWarping:
		return true
	if Globals.handler_mission != null and Globals.handler_mission.isMissionCompleted():
		return true
	elif Globals.handler_mission == null:
#		print("Globals.handler_mission == null")
		return true
	return false
	
func enableThruster(node):
	for n in node.get_children():
		n.emitting = true
#	node.get_node("Particle2D").emitting = true
	
func disableThruster(node):
	for n in node.get_children():
		n.emitting = false
#	node.get_node("Particle2D").emitting = false
	
func enableShifting():
	print("enableShifting")
	if isShifting or shiftCooldown > 0.0:
		return
	isShifting = !isShifting
	disableCollisionNodes()
	$Sprites.hide()
	disableAllThrusterParticles()
	disableBoosting()
#	getShield().unpowerShield()
		
func disableShifting():
	print("disableShifting")
	if not isShifting:
		return
	isShifting = !isShifting
	enableCollisionNodes()
	$Sprites.show()
	enableAllThrusterParticles()
	shiftCooldown = baseStats["shiftCooldown"]
	shiftDuration = baseStats["shiftDuration"]
#	getShield().powerShield()

func disableAllThrusterParticles():
	disableBoosting()
	for thruster in $ThrusterNodes.get_children():
		for n in thruster.get_children():
			n.emitting = false

func enableAllThrusterParticles():
	return
#	for thruster in $ThrusterNodes.get_children():
#		for n in thruster.get_children():
#			n.emitting = true
#	$ThrusterNodes/Aft_Boost/Particle2D.emitting = false
			
			
#	for n in $ThrusterNodes.get_children():
#		n.get_node("Particle2D").emitting = true
#	$ThrusterNodes/Aft_Boost/Particle2D.emitting = false

func x_unhandled_input(event):
	print("unhandled_input")
	if Input.is_action_pressed("fire"):
		mouseDown = true
#		
		if getActiveWeapon().canFire():
			getActiveWeapon().doFire(null)
		
	elif Input.is_action_just_released("fire"):
		mouseDown = false
	
func get_input(_delta):
	if not ready:
		return
#	print(extForces*_delta)
#	print("get_input")
	
	if Input.is_action_pressed("ui_select"):
		if can_warp_out():
#			print("can_warp_out")
			warpOutStepOne()
			
	if Input.is_action_just_pressed("alt_use_item"):
		if aItem >= 0: getActiveItem().doUse()
		
	if Input.is_action_pressed("fire"):
		mouseDown = true
#		
		if getActiveWeapon().canFire():
			getActiveWeapon().doFire(null)
	elif Input.is_action_just_released("fire"):
		mouseDown = false
		
	if Input.is_action_just_pressed("right_click"):
		enableShifting()
		print("right click")
	elif Input.is_action_just_released("right_click"):
		disableShifting()
		
	var input = Vector2.ZERO
	
	if Input.is_action_pressed("stop_move"):
		accel = Vector2.ZERO
		velocity = Vector2.ZERO
		extForces = Vector2.ZERO
		return Vector2.ZERO 
	
	if not isShifting:
	
		disableThruster($ThrusterNodes/Front)
		disableThruster($ThrusterNodes/Port)
		disableThruster($ThrusterNodes/Starboard)
		
		if Input.is_action_pressed("270"):
			enableThruster($ThrusterNodes/Port)
		if Input.is_action_pressed("90"):
			enableThruster($ThrusterNodes/Starboard)
		if Input.is_action_pressed("180"):
			enableThruster($ThrusterNodes/Front)
			if front_boosting and boostCharge == 0:
				disable_front_boosting()
		if Input.is_action_pressed("0"):
			enableThruster($ThrusterNodes/Aft)
			if aft_boosting and boostCharge == 0:
				disable_aft_boosting()
		else:
			disableThruster($ThrusterNodes/Aft)

#		if not is_aft_boosting():
#			if Input.is_action_just_pressed("0") and boostCharge > 0:
#				enable_aft_boosting()
#		elif Input.is_action_just_released("0"):
#			disable_aft_boosting()
		
		if not is_aft_boosting():
			if boostCharge > 0 and Input.is_action_pressed("0") and Input.is_action_just_pressed("hold_shift"):
				enable_aft_boosting()
		elif Input.is_action_just_released("hold_shift"):
			disable_aft_boosting()
			
		if not is_front_boosting():
			if Input.is_action_just_pressed("180") and boostCharge > 0:# and rotation_degrees > 35 and rotation_degrees < 125:
				enable_front_boosting()
		elif Input.is_action_just_released("180"):
			disable_front_boosting()
				
		if sideThrust:
			if sideThrustDuration <= 0.0 or Input.is_action_just_released("90") or Input.is_action_just_released("270"):
				disableSideThrusting()
#		elif sideThrustDuration == maxSideThrustDuration and Input.is_action_just_pressed("270") or Input.is_action_just_pressed("90"):
		elif sideThrustDuration > maxSideThrustDuration/2 and Input.is_action_just_pressed("270") or Input.is_action_just_pressed("90"):
			enableSideThrusting()
		
	handleMainBoostCharge(_delta)
	return Input.get_vector("180","0","270","90")
	
func disableSideThrusting():
	print("disableSideThrusting")
#	$ThrusterNodes/Port.get_node("Particle2D").process_material.scale /= 2
#	$ThrusterNodes/Starboard.get_node("Particle2D").process_material.scale /= 2
	sideThrust = false
	
func enableSideThrusting():
	print("enableSideThrusting")
#	$ThrusterNodes/Port.get_node("Particle2D").process_material.scale *= 2
#	$ThrusterNodes/Starboard.get_node("Particle2D").process_material.scale *= 2
	sideThrust = true
	
func isBoosting():
	if boosting == true:
		return true
	return false
	
func is_aft_boosting():
	return aft_boosting

func is_front_boosting():
	return front_boosting
	
func enable_aft_boosting():
	aft_boosting = true
	isRechargingBoost = false
#	$BoostRegen.stop()
	enableThruster($ThrusterNodes/Aft_Boost)

func disable_aft_boosting():
	aft_boosting = false
	isRechargingBoost = true
#	$BoostRegen.start()
	disableThruster($ThrusterNodes/Aft_Boost)
	
func enable_front_boosting():
	front_boosting = true
	isRechargingBoost = false
#	$BoostRegen.stop()
	enableThruster($ThrusterNodes/Front_Boost)

func disable_front_boosting():
	front_boosting = false
	isRechargingBoost = true
#	$BoostRegen.start()
	disableThruster($ThrusterNodes/Front_Boost)
	
func handleMainBoostCharge(_delta):
	if isRechargingBoost:
		boostCharge = min(boostMaxCharge, boostCharge + boostRegenTime * _delta)
		if boostCharge >= boostMaxCharge:
			isRechargingBoost = false
			
	if not sideThrust:
#		print("before: ", sideThrustDuration)
		sideThrustDuration = min(maxSideThrustDuration, sideThrustDuration + _delta/5)
#		print("after: ", sideThrustDuration)
		

func handleAimRectangle(_delta):
#	print("handleAimRectangle player")

	var angle:int = getActiveWeapon().deviation
	if angle == 0: 
		angle = 1
	
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
	

func xxhandleAngularRotation(_delta):
	
#	var old = rotation_degrees
#
#	rotation = lerp_angle(rotation, (Globals.MOUSE - global_position).angle(), agility/50)
#
#	print()
#	print(Engine.get_idle_frames())
#	print(rotation_degrees)
#
#	return

#	var amount_to_turn = agility * _delta  # or whatever
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
func handleAngularRotation(input_vec, delta):
	# 1. Calculate the angle we WANT to face (toward the mouse)
	var target_dir = global_position.direction_to(get_global_mouse_position())
	var target_angle = target_dir.angle()

	# 2. Smoothly rotate toward that angle
	# 'agility' acts as your rotation speed. 
	# Values between 5.0 and 15.0 usually match that arcade feel.
	
	if input_vec.x > 0:
		rotation = lerp_angle(rotation, target_angle, agility/4 * delta)
	else:
		rotation = lerp_angle(rotation, target_angle, agility * delta)
	
func xxxhandleAngularRotation(_delta):
	var forwardV = Vector2(cos(rotation), sin(rotation))
	rotation = forwardV.move_toward((Globals.MOUSE - global_position), _delta * agility).angle()

func xprocess_movement(delta):
	var thrust_vector:Vector2 = Vector2.ZERO
	
	var max_speed:int = enginePower/2
	
	var back_weight: float = 0.5   # Counter-thrust is 30% power
	var side_weight: float = 0.5   # Side-thrust is 60% power
	var forward_weight: float = 1.0 # Forward is 100% power

	var direction = get_input(delta)
	
	var drag_co:float = 2.0 # Higher = more "viscous" / snappy stops
	var boost_drag_co: float = 1.5 # Lower drag during boost = more sliding!
	var cur_max = enginePower / 2.0 # Baseline max speed
	
	handleAngularRotation(direction, delta)

	if direction != Vector2.ZERO:
		var dot = direction.dot(Vector2.RIGHT)
		var power_multiplier = forward_weight
		
		if dot < 0: 
			power_multiplier = lerp(side_weight, back_weight, abs(dot))
		else:
			power_multiplier = lerp(side_weight, forward_weight, dot)

		thrust_vector = direction.rotated(rotation)
		
		if aft_boosting:
			thrust_vector *= boostPower
			boostCharge = max(0, boostCharge - 60.0 * delta)
			max_speed *= boostPower/2
#			boost_on += delta
#			print(boost_on)
			
		accel = thrust_vector * (enginePower * power_multiplier)
		#velocity += accel * delta
	else:
		accel = Vector2.ZERO
		
	if direction.x == 1:
		gravity_vec = Vector2.ZERO
	else:
		gravity_vec = Globals.BASEGRAVITY * 3
		
	var cur_drag = drag_co
	
	if aft_boosting:
		cur_drag = boost_drag_co
		cur_max *= 1.8
		
	var drag_force = velocity * cur_drag
	
	var net_accel = accel - drag_force
	
	velocity += net_accel * delta
	
	
	mainUI.updateBoostChargeBar()

func xxprocess_movement(_delta):
		
	var direction = get_input(_delta)
#	print(direction)
	handleAngularRotation(direction, _delta)
	
	if isShifting:
		shiftDuration = max(0.0, shiftDuration - _delta)
		if shiftDuration <= 0.0:
			disableShifting()
	else:
		shiftCooldown = max(0.0, shiftCooldown - _delta)
	
#	if not isShifting:
	if not 0:
	#	print("playewr processmove")
	#	print(Engine.get_idle_frames())

		if direction:
			var thrust:Vector2 = (direction * enginePower/40)
#			thrust.y /= 3
			if aft_boosting:
				thrust.x *= boostPower * 1.0
				boostCharge = max(0, boostCharge - 60.0 * _delta)
			elif front_boosting:
#				print("ding")
				thrust.x *= boostPower * 0.5
				boostCharge = max(0, boostCharge - 60.0 * 1.5 * _delta)
				
			if sideThrust:
				thrust.y *= boostPower * 1.5
				sideThrustDuration = max(0.0, sideThrustDuration - _delta)
			else:
#				print("cutting side thrust")
				thrust.y *= 1.25

#			if thrust.x != 0:
#				if thrust.x < 0:
#					thrust.x *= 0.5
			if sideThrust:
				gravity_vec = Globals.BASEGRAVITY * 0.25
#				print(gravity_vec)
			elif thrust.x > 0 or position.y >= Globals.ROADY -5:
				gravity_vec = Vector2.ZERO
			elif thrust.x < 0:
				gravity_vec = Vector2.ZERO
			else:
				gravity_vec = Globals.BASEGRAVITY
			
			thrust = thrust.rotated(rotation)
#			print(thrust)
			accel += thrust
#			print(accel)

			if aft_boosting:
				accel = accel.limit_length(enginePower * boostPower)
			elif front_boosting:
				accel = accel.limit_length(enginePower * boostPower)
			elif sideThrust:
				accel = accel.limit_length(enginePower * boostPower)
			elif direction.x == 0:
				accel = accel.limit_length(enginePower)
			else:
				accel = accel.limit_length(enginePower)
							
		else:
			accel = Vector2.ZERO
			gravity_vec = Globals.BASEGRAVITY
		
		velocity += accel * _delta
		velocity = velocity.limit_length(enginePower*1)
#		friction = 2.0 * _delta
#		velocity = lerp(velocity, Vector2.ZERO, friction)

		mainUI.updateBoostChargeBar()
		
func limit_vector_magnitude(vector: Vector2, max_y: float) -> Vector2:
	var magnitude = sqrt(vector.x * vector.x + vector.y * vector.y)
	var desired_y = clamp(vector.y, -max_y, max_y)
	var new_x = (vector.x / magnitude) * sqrt(desired_y * desired_y + vector.x * vector.x)
	var new_y = desired_y
	return Vector2(new_x, new_y)
	
func do_init_gear():
	for n in items:
		n.doInit()

func addItemToUI(item):
	if item.type == 0: #actives
		item.full_ui_box.get_node("Vbox").remove_child(item.UI_node)
		item.full_ui_box.get_node("Vbox").remove_child(item.subPanel_Stats)
		mainUI.get_node("Place/Bottomleft/ItemsActive/HB").add_child(item.UI_node)
		mainUI.get_node("Place/BottomleftHigher").add_child(item.subPanel_Stats)
		item.subPanel_Stats.hide()
		item.full_ui_box.queue_free()
		if aItem == -1:
			for n in items:
				aItem += 1
				if item.id == n.id:
					#aItem = len(items)-1
					items[aItem].toggle()
					break
	elif item.type == 1: #stats
#		item.full_ui_box.get_node("Vbox").grow_horizontal = 1
#		item.full_ui_box.get_node("Vbox").grow_vertical = 1
		if item.full_ui_box.is_inside_tree():
			mainUI.get_node("LootNodes").remove_child(item.full_ui_box)
		mainUI.get_node("Pause_details/MC/VBC/HBC/PC/VBC/HBC").add_child(item.full_ui_box)
		item.subPanel_Stats.show()
	elif item.type == 2: #passives actives
#		item.full_ui_box.get_node("Vbox").grow_horizontal = 1
#		item.full_ui_box.get_node("Vbox").grow_vertical = 1
		if item.full_ui_box.is_inside_tree():
			mainUI.get_node("LootNodes").remove_child(item.full_ui_box)
		mainUI.get_node("Pause_details/MC/VBC/HBC/PC/VBC/HBC").add_child(item.full_ui_box)
		item.subPanel_Stats.show()
		
func addWeapon(weapon, mount = $Mounts/A):
	if not weapon:
		return
	mount.add_child(weapon)
	weapon.active = true
	weapon.isSelected = false
	weapon.shooter = self
	weapon.setFaction(faction)
	weapon.makeInvisible()
	weapon.doInit()
	weapon.doInitUI()
	
	if weapon.UI_node:
		weapon.full_ui_box.get_node("Vbox").remove_child(weapon.UI_node)
		weapon.full_ui_box.get_node("Vbox").remove_child(weapon.subPanel_Stats)
		Globals.curScene.get_node("UI/Place/Topleft/WeaponsOverview/VB").add_child(weapon.UI_node)
		Globals.curScene.get_node("UI/Place/TopleftLower/WeaponStatsPos").add_child(weapon.subPanel_Stats)
		weapon.subPanel_Stats.hide()
		
func addStartingWeapons():
	addWeapon(setShield())
	addWeapon(Globals.getWeaponBase("Autocannon"))
	addWeapon(Globals.getWeaponBase("Laserblaster"))
#	addWeapon(Globals.getWeaponBase("Mace"))
#	addWeapon(Globals.getWeaponBase("Twin Autocannon"))
#	addWeapon(Globals.getWeaponBase("Scattergatling+"))
#	addWeapon(Globals.getWeaponBase("Player Rail"))
#	addWeapon(Globals.getWeaponBase("Burstblaster")) 
#	addWeapon(Globals.getWeaponBase("Hvy Autocannon"))
#	addWeapon(Globals.getWeaponBase("Expl. Autocannon"))
#	addWeapon(Globals.getWeaponBase("Torpedolauncher"))
#	addWeapon(Globals.getWeaponBase("Swarmlauncher"))

func getShield():
	for n in $Mounts/A.get_children():
		if n.display == "Shield":
			return n
	return null

func setShield():
	var shield_omni = Globals.weapon_shield_omni.instance()
	shield_omni.construct(5, "Shield", baseStats.shieldStats)
	shield_omni.position = Vector2(-15, 0)
	shield_omni.connect("updateShield_UI_Nodes", mainUI, "_on_updateShield_UI_Nodes")
	shield_omni.connect("updateShieldBreakCooldown", mainUI, "_on_updateShieldBeakCooldown")
	shield_omni.shieldbar = Globals.UI.get_node("Bars/Panel/VBox/CC_HealthShield/VBox/Bar_Shield")
	
	return shield_omni
	
func addStartingItems():
##	addItem(Globals.getItemBase("Nearfield Deflector"))
#	return
	addItem(Globals.getItemBase("Reactive Armor"))
#	addItem(Globals.getItemBase("Conv. Bomb Rack (P)"))
#	addItem(Globals.getItemBase("Conv. Bomb Rack (P)"))
#	addItem(Globals.getItemBase("Orbital Strike: Beam (A)"))
	
	
#	addItem(Globals.getItemBase("Minelayer (P)"))
#	addItem(Globals.getItemBase("Hail Support: Fighter"))
#	addItem(Globals.getItemBase("Reactive Armor"))
#	addItem(Globals.getItemBase("Orbital Strike (Arty)"))
#	pass
#	addItem(Globals.getItemBase("Counterbarrage System"))
#	addItem(Globals.getItemBase("Nearfield Deflector"))
#	addItem(Globals.getItemBase("Orbital Strike (Beam)"))
#	for n in items:
#		print("#", n.id)
#		print("stacks: ", n.result[0].stacks)
#
#	items[0].result[0].stacks = 5
	
		
		
#	items[0].full_ui_box.queue_free()
#	items[0].UI_node.queue_free()
#	items[0].subPanel_Stats.queue_free()
#	items[0].full_ui_box = null
#	items[0].setQuality(1)
#	items[0].setQuality(2)
#	items[0].setQuality(0)
#	items[0].setQuality(-2)
#	items[0].doInitUI()
#	addItemToUI(items[0])
#	addItem(Globals.getItemBase("Conv. Bomb Rack"))
#	addItem(Globals.getItemBase("Missile Pod"))
#	addItem(Globals.getItemBase("Conv. Bomb Rack"))
#	addItem(Globals.getItemBase("Hail Support: Frigate"))
#	addItem(Globals.getItemBase("Health UP Shield DOWN"))

#	for n in items:
#		print("#", n.id)
#		print("stacks: ", n.result[0].stacks)

#	get = "Health+Shield+"
#	get = "Orbital Strike (Beam)"
#	get = "Orbital Strike (Arty)"
#	get = "Hail Support: Fighter"
#	item = Globals.getItemBase(get)
#	item.quality = 2
#	item.initQuality()
#	addItem(item)

func isLegalTarget():
	return true

func updateStats():
	setBaseStats()
	maxHealth = baseStats.maxHealth
	sideThrustDuration = maxSideThrustDuration
	boostMaxCharge = baseStats.boostMaxCharge
	
	for item in items:
		if item.trigger == "":
			for n in item.result:
				if n.prop in self and "isStat" in n and n.isStat == true:
					if n.amount != 0:
						#print(entry)
						match n.modType:
							"flat":
								self[n.prop] += n.amount
							"pct":
								self[n.prop] *= n.amount
	 
	health = min(health, maxHealth)
	
	emit_signal("update_player_health", health, maxHealth)
	mainUI.updateBoostChargeProps()
	mainUI.updateBoostChargeBar()
	
	updateShieldStats()
	
func updateShieldStats():
	var shield = getShield()
	if not shield: return
	shield.setShieldBaseStats()
	for item in items:
		if item.trigger == "":
			for n in item.result:
				if n.prop in shield and "isStat" in n and n.isStat == true:
					if n.amount != 0:
						#print(entry)
						match n.modType:
							"flat":
								shield[n.prop] += n.amount
							"pct":
								shield[n.prop] *= n.amount
	 
	
	shield.updateShield()
	
func reInitItems():
	for n in player.items:
		n.doInit()

func checkAggro(shooterObj):
	return
	
func handle_weapons(_delta):
	return
	
func handleItems(_delta):
	return
	
func init_debug_menu_entry():
	return
	
func update_debug_menu_entry():
	return
	
func updateDebugList():
	return
	
func handleControlNodes():
	return

func initSteering():
	return

func setMass():
	mass = 20.0

#func getRamDamasge():
#	return false
#	var ramBullet = Globals.BULLET_BLUE.instance()
#	Globals.curScene.get_node("Refs").add_child(ramBullet)
#	ramBullet.minDmg = 1
#	ramBullet.maxDmg = 1
#	ramBullet.impactForce = Vector2.ZERO
#	return ramBullet
	
func onWarpInDone():
	print("onWarpInDone")
	isWarping = false
	setActive()
#	enableCollisionNodes()
	do_init_gear()

func kill():
	return
	
func bound_process(_delta):
	position.x = clamp(position.x, 5, Globals.WIDTH -5)
	position.y = clamp(position.y, 5, Globals.ROADY -5)
	gravity_vec = Vector2.ZERO
	
#	print(position.y)

	if Globals.curScene.name != "Intermission":
		if time_since_ground_smoke > 0.1 and accel.length():
			time_since_ground_smoke = 0.0
			var smoke = Globals.SMOKE_GROUND.instance()
			Globals.curScene.get_node("Various").add_child(smoke)
			smoke.position = position + Vector2(sign(velocity.x) * 15, 0)
			smoke.emitting = true
		else: time_since_ground_smoke += _delta
		
		if position.y == Globals.ROADY - 5:
			if time_since_ground_dmg > 0.3:
				time_since_ground_dmg = 0.0
		#
				var ram = Globals.curScene.get_node("Various/Boundary").getRamDamage()
				ram.global_position = global_position + Vector2(0, 10)
				ram.velocity = Vector2(0, -10)

				takeDamage(ram, 3)
				ram.postImpacting()
			else: time_since_ground_dmg += _delta

func _on_BoostRegen_timeout():
	isRechargingBoost = true
	
func getStatByName(key):
	match key:
		"": return ""
		"maxHealth": return get(key)
		"maxShield": if getShield(): 
			return getShield().maxShield
		"healthRegenTime": return get(key)
		"shieldBreakTime":  if getShield(): 
			return str("%.1f" % getShield().shieldBreakTime)
		"shieldRegenTime":  if getShield():
			return str("%.1f" % getShield().shieldRegenTime)
		"enginePower": return get(key)
		"boostCharge": return str("%.1f" % get(key))
		"boostMaxCharge": return str("%.0f" % get(key))
		"boostPower": return str("%.1f" % get(key))
		"agility": return str("%.1f" % get(key))
		"materials": return get(key)
		"enginePower": return get("maxSpeed")
	return "null"

func hideSelf():
	hide()
#	for mount in $Mounts.get_children():
#		mount.get_node("Weapon/ControlNodes").hide()

	
func setShieldBarHealth():
	if shieldbar == null:
		return
	shieldbar.value = self.shield
	shieldbar.max_value = self.maxShield
	if shieldbar.has_node("Value"):
		shieldbar.get_node("Value").text = str(round(self.shield), " / ", self.maxShield)
