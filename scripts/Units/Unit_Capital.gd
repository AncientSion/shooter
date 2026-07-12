extends Air_Unit
class_name Capital

const CRASH_GRAVITY := 30.0
const CRASH_DRAG := 0.995
const CRASH_ROT_ACCEL_MIN := 0.3
const CRASH_ROT_ACCEL_MAX := 0.5
const CRASH_ROT_SPEED_MAX := 10.0

func _ready():
	for n in $ThrusterNodes.get_children():
		n.hide()
	canWarp = true
	
func _physics_process(_delta):
	pass

func getSpawnY(viewFrom, viewTo):
	var minY = Globals.HEIGHT / 2
	var add = Globals.HEIGHT / 4
	var y =  Globals.rng.randi_range(minY-add, minY)
	return y
	
func crash_step_one():
	$TimerNodes/CrashTimer.wait_time = 3.0
	$TimerNodes/CrashTimer.one_shot = true
	$TimerNodes/CrashTimer.connect("timeout", self, "crash_step_two")
	$TimerNodes/CrashTimer.start()
	for n in 1:
		add_exp_fire_smoke_fx(1.25, 0.3)

func crash_step_two():
	danger.fill(0.0)
	crashing = true

	# Keep existing momentum but damp it
	crash_velocity = velocity * 0.4
	velocity = Vector2.ZERO

	# Ensure some downward movement
	crash_velocity.y = max(crash_velocity.y, 10)
	crash_velocity.x = max(crash_velocity.x, 10) * direction.x

	crash_rotation_speed = 0
	crash_rotation_accel = rand_range(CRASH_ROT_ACCEL_MIN, CRASH_ROT_ACCEL_MAX)
	crash_rotation_accel *= direction.x
	
	for n in max_smoke:
		add_exp_fire_smoke_fx(1.0, rand_range(0, 1) * n*2)
		
	for n in max_smoke:
		var explo = Globals.getExplo("wreck", get_dmg_gfx_scale())
		explo.set_as_toplevel(true)
		explo.offset = get_point_inside_tex()
		explo.delay = rand_range(0.3, 1) * n + 3
		$EffectNodes.add_child(explo)
	
func crash(delta): # Slow descent
	crash_velocity.x += CRASH_GRAVITY * delta
	crash_velocity.y += CRASH_GRAVITY * delta

	# Slight air resistance
	crash_velocity *= CRASH_DRAG

	global_position += crash_velocity * delta

	# Ship gradually loses stability
	crash_rotation_speed += crash_rotation_accel * delta

	crash_rotation_speed = clamp(
	crash_rotation_speed,
	-CRASH_ROT_SPEED_MAX,
	CRASH_ROT_SPEED_MAX
	)

	rotation_degrees += crash_rotation_speed * delta
	
	rotation_degrees = clamp(rotation_degrees, -10, 10)

	if global_position.y >= Globals.HEIGHT - 30:
		crash_impact()

#const CRASH_ROT_ACCEL_MIN := 0.8
#const CRASH_ROT_ACCEL_MAX := 1.4
#const CRASH_ROT_SPEED_MAX := 10.0

func crash_impact():
	crashing = false

	global_position.y = Globals.HEIGHT - 30

	crash_rotation_speed = 0
	crash_velocity = Vector2.ZERO

	
func kill_by_crash():
	indestructable = true
	.kill_by_crash()

func get_crash_velo():
	return maxSpeed / 2
	
func disableBoosting():
	return

func setUnitFacing():
	if $SM.state == $SM.states.crash:
		return
		
	if curTarget == null:
		if moveTarget.x - position.x < 0:
			if $Sprites/Main.flip_h == false:
				do_turnaround()
		else:
			if $Sprites/Main.flip_h == true:
				do_turnaround()
	else: doFaceTarget()
	
func set_wander_target():
	var pos = global_position
	var rot = rotation_degrees
	var newTarget = Vector2.ZERO
	var limit = look_ahead + 1
	
	if direction.x == 1:
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
		
	moveTarget = newTarget

func can_warp_in():
	return true
	
func withdraw_condition(remDmg):
	if $SM.state != $SM.states.prepareWarpOut:
		var rand = rand_range(0, 1)
		if (health < float(maxHealth * stats.flee_tresh) and rand < remDmg / float(health)):
			print("flee_tresh: ", stats.flee_tresh)
			print("hit for: ", remDmg, ", health remaining: ", health ,"/", maxHealth)
			print("rand 0-1: ", str(rand), " < than: ", (remDmg / float(health)))
			print("flee triggered")
			return true
	return false
	
