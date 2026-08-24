extends Strikecraft_Unit
class_name Fighter

const CRASH_GRAVITY := 30.0
const CRASH_DRAG := 0.995
const CRASH_ROT_ACCEL_MIN := 0.3
const CRASH_ROT_ACCEL_MAX := 0.5
const CRASH_ROT_SPEED_MAX := 10.0

var display = "Fighter"
	
func do_specific_unit_init():
	if position.x < Globals.WIDTH / 2:
		rotation_degrees += Globals.rng.randi_range(-4, 4)
	else:
		rotation_degrees += 180 + Globals.rng.randi_range(-4, 4)
	
#	.doInit()
	velocity = (moveTarget - global_position).normalized() * maxSpeed/2
	accel = velocity
	rotation = velocity.angle()
	enginePower = maxSpeed
	
func _ready():
	pass

func _physics_process(_delta):
#	print("# ", self.id, ", rota: ", rotation_degrees)
	#print(rotation_degrees)
	pass
	
func set_direction(_dirVector = false):
	pass
	
func drift_process_movement(delta):

	# --- Tuning Parameters ---
	var agility = 20.0
	var turn_speed = 3.5
	var side_drag = 4.0

	# --- 1. Reset AI Intent ---
	accel = Vector2.ZERO
	set_interest()
	set_danger()
	choose_direction()
	

	# --- 2. Determine Desired Facing Direction ---
	var desired_world_dir = chosen_dir.rotated(rotation).normalized()
	var desired_angle = desired_world_dir.angle()

	# Rotate toward desired direction instead of snapping
	rotation = lerp_angle(rotation, desired_angle, turn_speed * delta)

	# --- 3. Apply Engine Thrust In Nose Direction ---
	var forward = Vector2.RIGHT.rotated(rotation)
	accel = forward * enginePower

	velocity += accel * delta

	# --- 4. Energy Maneuverability Model ---
	var travel_dir = velocity.normalized()
	var target_dir = forward.normalized()

	var dot = travel_dir.dot(target_dir)

	var turn_efficiency = lerp(0.8, 1.0, (dot + 1.0) / 2.0)
	var speed_modifier = turn_efficiency * (agility / 20.0)

	# --- 5. Apply Lateral Drag (Kills Sideways Sliding Slowly) ---
	var forward_velocity = velocity.project(forward)
	var lateral_velocity = velocity - forward_velocity

	velocity -= lateral_velocity * side_drag * delta

	# --- 6. Clamp Speed Instead of Normalizing ---
	var max_allowed_speed = maxSpeed * clamp(speed_modifier, 0.7, 1.2)
	velocity = velocity.clamped(max_allowed_speed)		
		
func process_movement(_delta):
	# 1. Reset and calculate AI intention
	var agility = 20.0
	accel = Vector2.ZERO
	set_interest()
	set_danger()
	choose_direction()

	# 2. Determine our desired engine push
	# We normalize chosen_dir first so diagonal inputs don't give "free" speed
	var thrust_direction = chosen_dir.rotated(rotation).normalized()
	accel = thrust_direction * enginePower

	# 3. Apply acceleration to velocity
	velocity += accel * _delta

	# 4. Energy Maneuverability (The "Air Resistance" Logic)
	# Compare current travel direction with where we want to go
	var travel_dir = velocity.normalized()
	var target_dir = accel.normalized()
	var dot = travel_dir.dot(target_dir) # 1.0 = straight, 0.0 = 90-degree turn

	# We use 'agility' to reduce the speed-loss penalty during turns.
	# Higher agility = closer to 1.0 (maintains speed better)
	var turn_efficiency = lerp(0.8, 1.0, (dot + 1.0) / 2.0) 
	var speed_modifier = turn_efficiency * (agility / 20.0)

	# 5. Lock speed and apply the "Air Grip"
	# We ensure the jet stays within its combat flight envelope
	velocity = velocity.normalized() * maxSpeed * clamp(speed_modifier, 0.7, 1.2)

	# 6. Update Visuals
	# The jet nose always follows the velocity vector
#	if not crashing and velocity.length() > 0.1:
	if velocity.length() > 0.1:
		rotation = velocity.angle()
		
func process_crash_rotation(delta):
	
	var dot = velocity.normalized().dot((moveTarget-global_position).normalized())
	print("crashing")
#	prinwwwwt(dot)
	if abs(dot) > 0.97:
		
		crash_rotation_speed += crash_rotation_accel * delta

		crash_rotation_speed = clamp(
		crash_rotation_speed,
		-CRASH_ROT_SPEED_MAX,
		CRASH_ROT_SPEED_MAX
		)

		rotation_degrees += crash_rotation_speed * delta * 3
		
#		rotation_degrees = clamp(rotation_degrees, -10, 10)
#		print(rotation_degrees)
		print(">")
			
func process_crash_movement(delta):
	var gravity = Vector2(0, 40)
	
	crash_velocity += gravity * delta
	crash_velocity *= 0.995   # air drag

	global_position += crash_velocity * delta
	rotation += crash_rotation_speed * delta

func shortest_angle_dist(from: float, to: float) -> float:
	var twoPi = TAU
	var delta = fmod(to - from, twoPi)
	if delta > PI:
		delta -= twoPi
	elif delta < -PI:
		delta += twoPi
	return delta
	
func bound_process(_delta):
	
	if $VisibilityNotifier2D.is_on_screen():
		print("bound_process #", self.id, ", on screen")
	else:
		print("bound_process #", self.id, ", NOT on screen")
		set_inactive()
		$Debug.show()
		showDebug()
		mark_debug_menu_entry_as_removed()
		return
		
	if position.y >= Globals.HEIGHT -5 or position.y <= Globals.ROADY -5:
		position.x = clamp(position.x, 5, Globals.WIDTH -5)
		position.y = clamp(position.y, 5, Globals.ROADY -5)
			
		var ram = Globals.curScene.get_node("Various/Boundary").getRamDamage()
		ram.minDmg *= 3
		ram.maxDmg *= 3
		ram.global_position = global_position + Vector2(0, 10)
		ram.velocity = Vector2(0, -10)

		take_damage(ram, ram.minDmg)
		ram.postImpacting()
	
func getSelfSpawnPosition(viewFrom, viewTo):
	var x:int = 0
	var	y:int = Globals.rng.randi_range(look_ahead, Globals.HEIGHT - look_ahead)
	
	if viewFrom == Vector2.ZERO and viewTo == Vector2.ZERO:
		x = Globals.WIDTH / 2 + (Globals.getRandomEntry([1, -1]) * Globals.rng.randi_range(200, Globals.WIDTH * 0.3))
	else:
		var legal = false
		while not legal:
			x = Globals.WIDTH / 2 + (Globals.getRandomEntry([1, -1]) * Globals.rng.randi_range(200, Globals.WIDTH * 0.3))
			if is_outside_viewport(x, y):
				legal = true
			
			
#
#		var xRng = Globals.rng.randi_range(100, 600)
#		var dir = Globals.getRandomEntry([-1, 1])
#		if dir == -1:
#			x = viewFrom.x - xRng
#		else: x = viewTo.x + xRng
#		x = clamp(x, 300, Globals.WIDTH-300)
	return Vector2(x, y)
	
func is_outside_viewport(x, y):
	var cam = Globals.curScene.get_node("CamA")
	var SCREEN = Globals.SCREEN
	var from = Vector2(cam.position - (SCREEN/2))
	var to = Vector2(from + SCREEN)
	
	if x > from.x and x < to.x and y > from.y and y < from.y:
		return false
	return true
		
#func get_point_inside_tex():
#	var valid = false
#	var tex = $Sprites/Main.get_texture().get_data()
#	tex.lock()
#
#	var tries:int = 0
#
#	while not valid:
#		tries += 1
##		print("looping!")
#		var pos = Vector2(Globals.rng.randi_range(0, texDim.x-1), Globals.rng.randi_range(0, texDim.y-1))
##		print(pos)
#		var p = tex.get_pixelv(pos)
#		if p[3] == 1:
#			return Vector2((-texDim.x/2)+pos.x, (-texDim.y/2)+pos.y) * $Sprites/Main.scale
#
#		if tries >= 100:
#			break
			
	
func enable_boosting():
	return false
		
func setUnitFacing():
	if velocity.x < 0 and sprite.flip_v == false:
		sprite.flip_v = true
		mirrorTurrets()
		mirrorThrusters()
	elif velocity.x > 0 and sprite.flip_v == true:
		sprite.flip_v = false
		mirrorTurrets()
		mirrorThrusters()
		
func mirrorThrusters():
	for n in $ThrusterNodes.get_children():
		n.position.y *= -1
		
func mirrorTurrets():
	$Mounts.scale.y *= -1
	return
	for n in $Mounts.get_children():
		n.position.x *= -1
#		if not n.has_node("Weapon"): return
		var weapon = n.get_node("Weapon")
		weapon.arc_midpoint_v.x *= -1
		weapon.current_rot_v.x *= -1
		weapon.rotation = weapon.current_rot_v.angle()

func getPossibleWeapons(index):
#	return false
#	var weapon = Globals.getWeaponBase("Light Missile");
	var weapon:Weapon_Base
	match index:
		0:
#			return null
			weapon = Globals.getWeaponBase("Light Machinecannon");
			weapon.fof = 9
#			weapon.rof = 1
		1:
			weapon = Globals.getWeaponBase("Light Missile");
			weapon.fof = 12
			weapon.steerForce *= 1.5
	weapon.makeInvisible()
	return weapon
	
func initAvoidValues():
	avoidValues = {"Player": 1.0, "Fighter": 1.0, "Helicopter_Light": 1.0, "Boundary": 5.0, "Obstacle": 5.0, "Cargohauler": 3.5, "City": 3.5}
	
func get_crash_velo():
	return ceil(maxSpeed * 1.15)
	
func crash_step_one():
	$Tween.interpolate_property(self, "maxSpeed", maxSpeed, get_crash_velo(), 3.0)
	$Tween.start()
#	$Tween.connect("tween_all_completed", self, "crash_step_two")
	
	for n in 1:
		add_exp_fire_smoke_fx(1.25, 0.3)
		
	crash_step_two()
	
func crash_step_two():
	danger.fill(0.0)
	crashing = true

	# Keep existing momentum but damp it
#	crash_velocity = velocity * 0.4
#	velocity = Vector2.ZERO

	# Ensure some downward movement
#	crash_velocity.y = max(crash_velocity.y, 10)
#	crash_velocity.x = max(crash_velocity.x, 10) * direction.x

	crash_rotation_speed = 0
	crash_rotation_accel = rand_range(CRASH_ROT_ACCEL_MIN, CRASH_ROT_ACCEL_MAX)
	crash_rotation_accel *= velocity.x
	
	if rotation_degrees > 55 and rotation_degrees < 125:
		moveTarget = global_position + (Vector2.RIGHT.rotated(rotation +  Globals.rng.randf_range(-0.3, 0.3)) * Globals.rng.randi_range(600, 900))
	elif velocity.x > 0:
		moveTarget = Vector2(global_position.x + (Globals.HEIGHT-global_position.y)*2.5, Globals.HEIGHT)
	elif velocity.x < 0:
		moveTarget = Vector2(global_position.x - (Globals.HEIGHT-global_position.y)*2.5, Globals.HEIGHT)
		
#	maxSpeed *= 1.3
#	enginePower *= 0.3
	
#	crash_velocity = velocity
#	velocity = Vector2.ZERO
#	crash_rotation_speed = Globals.rng.randf_range(-0.5, 0.5)
	
#	var timer = Timer.new()
#	$TimerNodes.add_child(timer)
#	timer.name = "CrashExploTimer"
#	var time:float = Globals.rng.randf_range(7.0, 10.0)
#	timer.wait_time = time
#	timer.one_shot = true
#	timer.autostart = true
#	timer.start()
#	timer.connect("timeout", self, "_on_crash_explo_timer_timeout")

func _on_crash_explo_timer_timeout():
	kill()

func crash_impact():
	print("crash_impact")
	crashing = false
	global_position.y = Globals.HEIGHT - 30
	crash_rotation_speed = 0
	crash_velocity = Vector2.ZERO

func kill_by_crash():
	print("kill_by_crash")
	if $SM.state == $SM.states.crash:
		kill()
		$ThrusterNodes/Aft/Particle2D.emitting = false
		if rotation_degrees > 55 and rotation_degrees < 125:
			hide()
	else:
		if global_position.x < 50 or global_position.x > Globals.WIDTH - 50:
#			global_rotation_degrees += 180
			velocity *= -1
			accel *= -1

func setMixUpWanderTarget():
	print("setMixUpWanderTarget #", self.id)
	if velocity.x > 0:
		moveTarget.x = global_position.x - look_ahead*2
	elif velocity.x < 0:
		moveTarget.x = global_position.x + look_ahead*2
		
	checkMoveTargetWithinBoundary()

func set_wander_target():
	if  Globals.rng.randf_range(0, 1) < 0.08:
		return setMixUpWanderTarget()
		
	var pos = global_position
	var rot = rotation_degrees
	var newTarget = Vector2.ZERO
	var limit = look_ahead
	
	if rotation_degrees > -90 and rotation_degrees < 90:
		newTarget = pos + Vector2(look_ahead, Globals.getRandomEntry([1, -1]) * 15)
	else:
		newTarget = pos + Vector2(-look_ahead, Globals.getRandomEntry([1, -1]) * 15)
		
	if newTarget.x > Globals.WIDTH - limit:
		newTarget.x -= limit *4
	elif newTarget.x < 0 + limit:
		newTarget.x += limit *4
	
#	if newTarget.y > Globals.HEIGHT:
#		newTarget.y -= Globals.HEIGHT
#	elif newTarget.y < 0:
#		newTarget.y += Globals.HEIGHT
	
	moveTarget = newTarget
	
func checkMoveTargetWithinBoundary():
	if $SM.state != $SM.states.crash:
		moveTarget.x = clamp(moveTarget.x, look_ahead, Globals.WIDTH - look_ahead)
		moveTarget.y = clamp(moveTarget.y, look_ahead, Globals.HEIGHT - look_ahead)
	pass
	
func is_legal_target(target_unit):
	return target_unit.global_position.y < Globals.HEIGHT - 200 and target_unit.global_position.y > 200

func add_exp_fire_smoke_fx(scale:float, delay:float):
#	add_exp_fire_smoke_fx(scale, delay)
	var pos = get_point_inside_tex()
	var explo = Globals.getExplo("radial", scale, delay)
	explo.position = pos
	$EffectNodes.add_child(explo)
	var node = Globals.getFireSmokeNode(scale, delay + 0.2)
	node.position = pos
	$EffectNodes.add_child(node)

func get_dmg_gfx_scale():
	return 1
	
func crash_condition(remDmg):
	if $SM.state != $SM.states.crash:
		return true
	return false
	
func withdraw_condition(remDmg):
	if $SM.state != $SM.states.withdraw:
		var rand =  Globals.rng.randf_range(0, 1)
		if (health < float(maxHealth * stats.flee_tresh) and rand < remDmg / float(health)):
			print("flee_tresh: ", stats.flee_tresh)
			print("hit for: ", remDmg, ", health remaining: ", health ,"/", maxHealth)
			print("rand 0-1: ", str(rand), " < than: ", (remDmg / float(health)))
			print("flee triggered")
			return true
	return false
