extends Base_Entity
class_name Base_Unit

export(Resource) var stats

var interest = []
var danger = []
var ray_directions = []
var ray_degree = []
var chosen_dir = Vector2.ZERO

export var num_rays = 16
export var look_ahead:int

var moveTarget = Vector2.ZERO
var startPos = Vector2.ZERO
var direction = Vector2.ZERO
var accel = Vector2.ZERO
var velocity = Vector2.ZERO
var extForces = Vector2.ZERO
var gravity_vec = Vector2.ZERO
var maxSpeed:int
var weapons = Array()
var aWeapon:int = 0

var sightRange:int = 0
var coreRange:int = 50

var activeBehavior:int = 0

var ready = true
var dmgBreaks = []

var ram

onready var sprite = $Sprite
onready var state_m = $SM

func _ready():
#	print("_ready Base_Unit ", self.display)
	maxSpeed = speed
	maxSmoke = ceil(texDim.length() / 100)
	setDamageBreaks()
#	print("max smoke: ", maxSmoke)
	add_to_group("isUnit")
	set_physics_process(true)
	initSteering()
	
func addSightCollision():
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
	mass = stepify(pow(maxHealth, 0.3), 0.01)
	print(self.display, ": ", mass, " mass")

func getDamageObject():
	return ram
	
func setDamageBreaks():
	for n in maxSmoke:
		dmgBreaks.append(100/(maxSmoke+1)*(n+1))
	
func checkHealthAfterDmg(remDmg):
	if health <= 0:
		kill()
	elif crashIsTriggered(remDmg):
		print("crash")
		$SM.set_state($SM.states.crash)
	else:
		if smoke >= maxSmoke: return
#		var fraction:float = float(health) / maxHealth
		var fraction:float = float(health) / maxHealth * 100
		if fraction < dmgBreaks[len(dmgBreaks)-1]:
			dmgBreaks.pop_back()
			smoke += 1
			var smoke = Globals.getSmokeNode(0.5)
			var fire = Globals.getFireNode(0.5)
			var point = getPointInsideTex()
			smoke.position = point
			fire.position = point
			addEffectNode(smoke)
			addEffectNode(fire)
	return false
	
func setupCrashing():
	pass
	
func crashIsTriggered(remDmg):
	return false
	
func doInit():
#	$TimerNodes/BehaveTimer.start()
	randomizeWeaponStartCooldown()
	if lifetime > 0.0:
		var label = Globals.DMG_LABEL.instance()
		$ControlNodes.add_child(label)
		label.offset = Vector2(0, max(40, texDim.y + 10))
#		label.position = 
		label.init_lifetime_counter(lifetime)
#
#	var aggroleave = CollisionShape2D.new()
#	aggroleave.name = "CollisionShape2D"
#	aggroleave.shape = CircleShape2D.new()
#	aggroleave.shape.radius = sightRange * 1.2	
#	$AggroLeave.add_child(aggroleave)
#
	$Debug/moveTarget.set_as_toplevel(true)
	$Debug/moveTarget.show()
	$Debug/Line2D.set_as_toplevel(true)
	$Debug/Line2D.show()
	$Debug/C/stats.set_as_toplevel(true)
	$Debug/C/stats.show()
	$Debug/C/behav.set_as_toplevel(true)
	$Debug/C/behav.show()
	
	
	if not $Debug.visible:
		$Debug/moveTarget.hide()
		$Debug/Line2D.hide()
		$Debug/C/stats.hide()
		$Debug/C/behav.hide()
		
	initAIList()
	addPhysCollision()
	addSightCollision()
	
func randomizeWeaponStartCooldown():
	for weapon in weapons:
		if weapon.rof != 0:
			weapon.cooldown = rand_range(0, weapon.rof*2)
			#print(weapon.cooldown,  "/", weapon.rof)

func _process(delta):
	if isWarping:
#		print("isWarping")
		$Jump.position = global_position
#		$Jump.text = str(velocity.round

	if extForces.length() < 4:
		extForces = Vector2.ZERO
#		print(Engine.get_idle_frames())
#		print(extForces)

func _draw():
	drawSight()
	drawCore()

func drawSight():
	return
	draw_arc(Vector2.ZERO, sightRange, 0, TAU, 24, Color(1, 0, 0, 1), 1)
	
func drawCore():
	return
	draw_arc(Vector2.ZERO, coreRange, 0, TAU, 24, Color(1, 1, 0, 1), 1)
	
func _physics_process(_delta):
	if destroyed or not ready: 
		return
		
	updateDebugList()
	updateAIList()
	
	if has_node("SM"):
		$SM._process_state_logic(_delta)
	else:
		processMovement(_delta)
	
	if not canBeOutOutBounds() and Globals.isOutOfBounds(position):
		kill()
		return
	if extForces:
#		print(extForces)
		extForces *= 0.97
#		extForces = Vector2.ZERO
	handleWeapons(_delta)
	
func handleControlNodes():
#	return
	for n in $ControlNodes.get_children():
		n.rect_position = global_position + n.offset
		
func processMovement(_delta):
	pass
#	print("processMovement BASE UNIT")
#	position += velocity * _delta
#	velocity += extForces
	
func canBeOutOutBounds():
	return false

func handleWeapons(_delta):
	if targets.size() == 0: return
	for index in len(weapons):
		if not is_instance_valid(weapons[index]) or weapons[index].destroyed: continue
		if weapons[index].weaponHasValidTarget() == false:
			weapons[index].setWeaponTarget(targets)
		if weapons[index].curTarget == null:
			continue
		weapons[index].doTrackTarget(curTarget, _delta)
		fireGuns(index)
		
func initAIList():
	if debug_ui_node != null: return
	debug_ui_node = Globals.curScene.get_node("UI/Place/Topright/AI_PC/VBoxC/HBox").duplicate()
	Globals.curScene.get_node("UI/Place/Topright/AI_PC/VBoxC").add_child(debug_ui_node)
	debug_ui_node.get_child(0).text = self.display
	debug_ui_node.get_child(4).text = str("")
	updateAIList()
#	debug_ui_node.get_child(1).text = str(position)
#	debug_ui_node.get_child(2).text = str(activeBehavior)
#	debug_ui_node.get_child(5).text = str(health, "/", self.maxHealth)
		
func updateAIList():
	if debug_ui_node != null:
		debug_ui_node.get_child(1).text = str(round(position.x), " / ", round(position.y))
		#debug_ui_node.get_child(2).text = str(round(velocity.x), " / ", round(velocity.y))
		debug_ui_node.get_child(2).text = str(round(velocity.length()))
		debug_ui_node.get_child(3).text = str(accel.round(), ", ", round(accel.length()))
		debug_ui_node.get_child(4).text = str(extForces.round())
#		var keys = $UnitSM.states.keys()
#		print(keys)
		if not has_node("SM"): 
			return
		var state = $SM.state
#		print(state)
#
#		print(keys[state])
		debug_ui_node.get_child(5).text = str(state)
		debug_ui_node.get_child(6).text = str(getTargetDisplay())
		debug_ui_node.get_child(7).text = str(health, "/", maxHealth)

func updateDebugList():
	$Debug/C/behav.rect_position = global_position + Vector2(-30, 50)
	$Debug/C/stats.rect_position = global_position + Vector2(-30, 100)
	$Debug/C/stats.text = str("#", id, "\n", accel.round())
	
	$Debug/moveTarget.rect_position = moveTarget - Vector2(20, 10)
	$Debug/Line2D.points[0] = global_position
	$Debug/Line2D.points[1] = moveTarget

func getTargetDisplay():
	if curTarget == null or not is_instance_valid(curTarget):
		return null
	else: return curTarget.display
	
func setInactive():
	set_physics_process(false)
	ready = false
	$ColNodes/DmgNormal.monitoring = false
	$ColNodes/DmgNormal.monitorable = false
	for n in $TimerNodes.get_children():
		n.stop()
	if debug_ui_node != null and is_instance_valid(debug_ui_node):
		debug_ui_node.hide()

func setActive():
	set_physics_process(true)
	ready = true
	$ColNodes/DmgNormal.monitoring = true
	$ColNodes/DmgNormal.monitorable = true
	for n in $TimerNodes.get_children():
		n.start()
	if debug_ui_node != null:
		debug_ui_node.show()
	
func setupDelayedWarpIn(time):
	hideSelf()
	setInactive()
	var timer = Timer.new()
	Globals.curScene.add_child(timer)
	timer.connect("timeout", self, "doDelayedWarpIn", [timer])
	timer.wait_time = time
	timer.start()

func hideSelf():
	hide()
	for mount in $Mounts.get_children():
		mount.get_node("Weapon/ControlNodes").hide()
		
func doDelayedWarpIn(timer):
	visible = true
	timer.queue_free()
	doWarpIn()
	
func doWarpIn():
	isWarping = true
	visible = true
	
	enableItemsAndWeapons()
	
	$Jump.visible = true
	if has_node("ShieldPos"):
		$ShieldPos.visible = true
		$ShieldPos.modulate.a = 0
	$Sprite.modulate.a = 0
	$Jump.scale = Vector2(0, 0)
	
	
	
#	$ThrusterNodes.visible = false
	$Mounts.visible = false
#	$ControlNodes.visible = false
#	$Jump.visible = true
#	$Sprite.modulate.a = 0
	
	var durIn = 1.0 * Globals.mod / 5
	$Tween.interpolate_property($Jump, "scale",
			Vector2(0, 0), Vector2(10, 1), durIn,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			
	$Tween.start()
	yield($Tween, "tween_all_completed")
			
	$Tween.interpolate_property($Jump, "scale",
			Vector2(10, 1), Vector2(20, 15), durIn,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			
	$Tween.start()
	yield($Tween, "tween_all_completed")
			
	setActive()
	$ThrusterNodes.visible = true
	$Mounts.visible = true
	if has_node("ControlNodes"):
		$ControlNodes.visible = true
	
	var durOut = 1.0 * Globals.mod / 5
	$Tween.interpolate_property($Jump, "scale",
			Vector2(20, 15), Vector2(0, 0), durOut,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($Sprite, "modulate:a",
			0.0, 1.0, durOut,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($Sprite, "scale",
			Vector2(0, 0), $Sprite.scale, durOut/2,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			
	if has_node("ShieldPos"):
		$Tween.interpolate_property($ShieldPos, "modulate:a",
			0.0, 1.0, durOut,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			
	$Tween.interpolate_property($ThrusterNodes, "modulate:a",
			0.0, 1.0, durOut/2,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			
	$Tween.interpolate_property($Sprite, "scale",
			Vector2(0, 0), Vector2(1, 1), durOut/2,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

	$Tween.start()
	yield($Tween, "tween_all_completed")
	emit_signal("hasWarpedIn")
	isWarping = false
	
	$Jump.visible = false
#	$Jump.scale = Vector2(0, 0)
	$Jump.modulate.a = 1
	
	
	setActive()
	#$ShieldRegen.wait_time = shieldRegenTime
	powerShield()
	Globals.curScene.onPlayerWarpIn()
	
	for mount in $Mounts.get_children():
		if mount.has_node("Weapon"):
			mount.get_node("Weapon/ControlNodes").show()
			
func powerShield():
	return
	
func doWarpOut():
	isWarping = true
	$Jump.visible = true
	
	disableItemsAndWeapons()
	
	if has_node("ShieldPos"):
		$ShieldPos.visible = false
	if has_node("Items"):
		for n in self.items:
			n.set_physics_process(false)
			n.doStopUse()
			n.doReset()
			n.setUICooldown()
		
	var durOut = 1.0 * Globals.mod / 5
	
	$Tween.interpolate_property($Jump, "scale",
			Vector2(0, 0), Vector2(20, 15), durOut,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

	$Tween.start()
	yield($Tween, "tween_all_completed")
	
	$EffectNodes.visible = false
	$ControlNodes.visible = false
	$ThrusterNodes.visible = false
	$Mounts.visible = false
	
	var durIn = 2.0 * Globals.mod / 5
	$Tween.interpolate_property($Jump, "scale",
			Vector2(20, 15), Vector2(10, 1), durIn,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			
	$Tween.interpolate_property($Sprite, "modulate:a",
			1.0, 0.0, durOut,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($ThrusterNodes, "modulate:a",
			1.0, 0.0, durOut/2,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			
	$Tween.interpolate_property($Sprite, "scale",
			Vector2(1, 1), Vector2(0, 0), durOut/2,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			
	$Tween.start()
	yield($Tween, "tween_all_completed")
	
	$Tween.interpolate_property($Jump, "scale",
			Vector2(10, 1), Vector2(0, 0), durIn,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			
	$Tween.start()
	yield($Tween, "tween_all_completed")
	setInactive()
	
	emit_signal("hasWarpedOut")
	isWarping = false
#	shield = 0
#	ui.get_node("Bars/Panel/Shield/Value").text = str(shield, " / ", maxShield)
#	Globals.call_deferred("doAdvanceLevel")
	
func getSelfSpawnPosition(viewFrom, viewTo):
#	print("getSpawnPos Base")
#	print(viewFrom, viewTo)
	var x = getSpawnX(viewFrom, viewTo)
	var y = getSpawnY(viewFrom, viewTo)
	return Vector2(x, y)
	
func getSpawnX(viewFrom, viewTo):
	var xRng = Globals.rng.randi_range(300, 400)
	var dir = Globals.getRandomEntry([-1, 1])
	var x = 0
	if dir == -1:
		x = viewFrom.x - xRng
	else: x = viewTo.x + xRng
	x = clamp(x, 300, Globals.WIDTH-300)
	return x
	
func getSpawnY(viewFrom, viewTo):
	var variance = 400
	var y = Globals.HEIGHT/2 + Globals.rng.randi_range(-variance, variance)
	return y
		
func unitHasValidTarget():
	if curTarget != null and is_instance_valid(curTarget) and curTarget.real:
		if curTarget.destroyed or not curTarget.ready:
			curTarget = null
		elif global_position.distance_to(curTarget.global_position) < sightRange * 1.5:
			return true
	return false

func fireGuns(index):
	weapons[index].handleFiring()
	handlePostFire()
	
func handlePostFire():
	return

func setTarget():
	var targetgroup = "friendly"
	if is_in_group("friendly"):
		targetgroup = "hostile"
	
	var allTargets = get_tree().get_nodes_in_group(targetgroup)
	var targets = Array()
	for n in allTargets:
		if not n.isLegalTarget(): continue
		var dist = global_position.distance_to(n.global_position)
		#print("dist to ", n.display, ": ", int(dist))
		if dist < sightRange:
			targets.append(n)
		
	#print(targets)
	if len(targets):
		curTarget = Globals.getRandomEntry(targets)
	else: curTarget = null
	
	#if target: print("target: ", target.display)
	
	#target = get_node("/root/Main/Player")
	#return
	
#	var missionHandler = get_node("/root/Main/MissionHandler")
#	if missionHandler.mission.type == "Protect Skyscraper":
#		var targets = get_tree().get_nodes_in_group("skyscraper")
#		for option in targets:
#			if option.destroyed: continue
#			if Globals.rng.randf() < 0.2:
#				target = option
#				break
	
	#print("setting target for ", self.display, " to ", target.display)

func setDirection(dirVector = false):
	if dirVector:
		direction = dirVector
	else:
		direction = Vector2(Globals.getRandomEntry([-1, 1]), 0)
	
	if direction == Vector2(-1, 0):
		direction *= -1
		doTurnaround()
		
	#print(self.display, " set dir to ", direction)
	
func doTurnaround():
	direction *= -1
	$Sprite.flip_h = !$Sprite.flip_h
	mirrorTurrets()
	mirrorThrusters()
	mirrorVarious()
	mirrorColNodes()

func mirrorTurrets():
	for n in $Mounts.get_children():
		n.position.x *= -1
		if not n.has_node("Weapon"): return
		var weapon = n.get_node("Weapon")
		weapon.anchor.x *= -1
		weapon.current_rot.x *= -1
		weapon.rotation = weapon.current_rot.angle()
		
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
	if $Sprite.flip_h == true:
		$ColNodes.rotation = -(2*rotation)
	else: $ColNodes.rotation = 0

func setArmament():
#	print("setArmament")
	var count = 0
	for mount in $Mounts.get_children():
		var weapon = getPossibleWeapons(count)
		count += 1
		if !weapon: continue
		mount.add_child(weapon)
		mount.faction = faction
		weapon.anchor =  Vector2.RIGHT.rotated(deg2rad(mount.startAngle))
		weapon.current_rot = weapon.anchor
		weapon.rotation = weapon.current_rot.angle()
		weapon.maximum_rotation = deg2rad(mount.maximum_rotation)
		weapon.turnrate = deg2rad(mount.turnrate)
		weapon.set_owner(mount)
#		weapon.addHealthBar()
		if mount.health == 0:
			mount.makeUntargetable()
		if mount.turnrate == 0:
			weapon.canRotate = false


		weapon.shooter = self
		weapons.append(weapon)
		
		if faction == 0:
			mount.setFriendly()
			weapon.setFriendly()
		elif faction == 1:
			mount.setHostile()
			weapon.setHostile()
		elif faction == 2:
			mount.setNeutral()
			weapon.setNeutral()
	
func getPossibleWeapons(index):
	return
	
func _on_lifetime_timeout():
	print("_on_lifetime_timeout")
	doWarpOut()

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

func createRessources():
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

func forceLockOnTarget(hardTarget):
	curTarget = hardTarget
	for n in weapons:
		n.target = hardTarget
		n.locked = true
	
func setWrecked():
	health = Globals.rng.randi_range(ceil(maxHealth*0.1), ceil(maxHealth * 0.3))
	destroyed = true
	for n in $Mounts.get_children():
		n.kill()
		
func kill():
	if destroyed: return
#	#print("kill unit")
#	emit_signal("objectiveDestroyed")
	if has_node("BehaveTimer"):
		$TimerNodes/BehaveTimer.stop()
	for n in weapons:
		n.kill()
	.kill()
	#queue_free()
	
func get_class():
	return str("Unit_Base")#, ", self.display)
	
func isLegalTarget():
	if destroyed or not ready or indestructable:
		return false
	return true
	
func applyForce(force):
#	print("applying force on ", self.display, ": ", force/maxHealth)
	extForces += force/mass

func removeTarget():
	for n in targets:
		if curTarget == n:
			targets.erase(n)
			curTarget = null
			break
	for n in weapons:
		n.curTarget = null

func setNewTarget():
	if not targets.size():
		return
	curTarget = targets[0]
	state_m.set_state(state_m.states.close)
	

func _on_Sight_area_entered(area):
#	return
	if area.owner.isObstacle or self == area.owner or self.faction == area.owner.faction:
		return
	for n in targets:
		if n == area.owner:
			return
	targets.append(area.owner)
	setNewTarget()


func _on_AggroLeave_area_exited(area):
	var index = -1
	for n in targets:
		index += 1
		if n == area.owner:
			break
	
	if index > -1:
		targets.erase(area.owner)
	
func disableItemsAndWeapons():
	for n in $Weapons.get_children():
		n.doDisable()
	return
	
func enableItemsAndWeapons():
	for n in $Weapons.get_children():
		n.doEnable()
	if isPlayer:
		weapons[aWeapon].toggle()
	return

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
		
		var line = Line2D.new()
		line.name = str(i)
		line.width = 3
		line.default_color = Color(0, 0, 0, 1)
		line.add_point(Vector2.ZERO)
		line.add_point(Vector2.RIGHT.rotated(angle) * look_ahead)
		
#		print(line.points)
		
		$Debug/new.add_child(line)


func set_interest():
	
#	set_default_interest()
#	return
	
	if moveTarget:
		var path_direction: Vector2 = (moveTarget - global_position).normalized()
		for i in num_rays:
			var d = ray_directions[i].rotated(rotation).dot(path_direction)
			interest[i] = max(0, d)
	else:
		set_default_interest()
		
func set_default_interest():
	for i in num_rays:
		var d = ray_directions[i].rotated(rotation).dot(transform.x)
		interest[i] = max(0, d)

func set_danger():
	var space_state = get_world_2d().direct_space_state
	for i in num_rays:
		var result = space_state.intersect_ray(
			position,
			position + ray_directions[i].rotated(rotation) * look_ahead, [self], 0b10000, false, true
		)
		if result:
			danger[i] = getDangerValueFromEntity(result.collider.owner.display)
		else:
			danger[i] = 0.0
			
func getDangerValueFromEntity(display):
	pass

func choose_direction():
	for i in num_rays:
		$Debug/new.get_child(i).default_color = Color(0, 0, 0, 1)
		if danger[i] > 0.0:
			interest[i] -= danger[i]
			$Debug/new.get_child(i).default_color = Color(1, 0, 0, 1)
#		$Debug/new.get_child(i).points[1] = Vector2.RIGHT.rotated(i * 2 * PI / num_rays) * look_ahead * interest[i]
		$Debug/new.get_child(i).points[1] = ray_directions[i] * look_ahead * interest[i]
		
		
	chosen_dir = Vector2.ZERO
	for i in num_rays:
		chosen_dir += ray_directions[i] * interest[i]
	chosen_dir = chosen_dir.normalized()

func updateShield():
	return
