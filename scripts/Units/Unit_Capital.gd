extends Air_Unit
class_name Capital
	
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
	
func killByCrash():
	indestructable = true
	.killByCrash()

func getCrashSpeed():
	return maxSpeed / 2
	
func getCrashAngle():
	return round(rand_range(13, 18))
	
func disableBoosting():
	return

func setUnitFacing():
	if $SM.state == $SM.states.crash:
		return
		
	if curTarget == null:
		if moveTarget.x - position.x < 0:
			if $Sprites/Main.flip_h == false:
				doTurnaround()
		else:
			if $Sprites/Main.flip_h == true:
				doTurnaround()
	else: doFaceTarget()
	
func setNewWanderTarget():
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
