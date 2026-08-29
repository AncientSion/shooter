extends Base_Entity
class_name Weapon_Base

var type:int
var projSize:float
var projNumber:int
var burst:int
var rof:float
var minDmg:int
var maxDmg:int
var aoe:int
var speed:int
var dmgType:int
var deviation:int
var linearDevi:bool
var burstDelay:float
var texture
var turnrate:float
var minFireDist:int = 0
var isFiring = false

var max_range:int = 0

var canRotate = true

var baseProps:Dictionary

var shooter = null
var active = false
var isSelected:bool = false
var forcedDisabled = false
var owner_mount:Base_Mount = null

#var arc = Vector2()

var cooldown:float = 0.0
var burstCooldown:float = 0.0
var bursting:int = 0

var fof = 3
var fof_rad:float
var vLaunch = false

var display:String
var notes:String

var time:float

var arc_midpoint_v: Vector2# = Vector2.RIGHT.rotated(rotation)
var current_rot_v: Vector2#= arc_midpoint_v
#var maximum_rotation: float# = PI / 6.0 # 30

signal hasFired

func _ready():
	fof_rad = deg2rad(fof)
	pass
	
func do_init_weapon():
#	print("_ready weapon BASE #", id, "__", display, "___", $Sprite.scale)
	texDim = Vector2($Sprites/Main.texture.get_width() * $Sprites/Main.scale.x, $Sprites/Main.texture.get_height() * $Sprites/Main.scale.y)
	isWeapon = true
	$Muzzle/AnimatedSprite.stop()
	$Muzzle/AnimatedSprite.hide()
	$Muzzle/AnimatedSprite.frame = 0
	connectHurtBoxes()
	drawAimVector()
	do_sub_init_weapon()
	check_init_aimdebug()
	
func do_sub_init_weapon():
	pass
	
func check_init_aimdebug():
	if Globals.AIMDEBUG and faction != 0:
		if !has_node("ControlNodes/rem_cooldown_label"):
			init_cooldown_debug_label()
		if active:
			$LineAim.show()
		else:
			$LineAim.hide()

func _draw():
	if Globals.AIMDEBUG and faction != 0:
		return
		drawRange()
		
func drawRange():
	draw_arc(Vector2.ZERO, speed * lifetime * 0.5, 0, TAU, 12, Color(1, 0, 0, 1), 10)
	
func _physics_process(_delta):
	if active:
#		if faction == 1:
#			print(rotation)
		weapon_process(_delta)
	
func weapon_process(_delta):
	if is_in_active_burst():
		handle_burst_cooldown(_delta)
	else:
		cooldown = max(cooldown - _delta, 0.0)
	update_cooldown_ui_nodes()
	
func update_cooldown_ui_nodes():
	if UI_node != null:
		UI_node.get_node("PC/CDProgress").value = cooldown/rof*100
	if Globals.AIMDEBUG and faction != 0 and has_node("ControlNodes/rem_cooldown_label"):
		$ControlNodes.get_node("rem_cooldown_label").update_label(cooldown)
		
func is_in_active_burst():
	if burst > 1 && bursting:
		return true
	return false

func constructWpn(props):
	for key in props:
		var value = props[key]
		if key in self:
			self[key] = value
	
	baseProps = props
	cooldown = props.rof
	burstCooldown = props.burstDelay
	max_range = speed * lifetime
	setRecoilForce()
	
func setRecoilForce():
	recoilForce = Globals.getRecoilForce(minDmg, maxDmg, speed)

func has_fire_solution(target) -> bool:
	if not is_instance_valid(target):
		return false

	var dist_sq: float = global_position.distance_squared_to(target.global_position)
#	if dist_sq < min_fire_dist * min_fire_dist:
#		return false
#	if dist_sq > max_fire_dist * max_fire_dist:
#		return false

	return abs(get_angle_to(target.global_position)) < fof_rad
	
	

func xhas_fire_solution(target) -> bool:
	if global_position.distance_squared_to(target.global_position) < minFireDist * minFireDist:
		return false

	var dir_to_target = target.global_position - global_position
	var angle_to_target = dir_to_target.angle() 

	var dif = wrapf(
		angle_to_target - global_rotation,
		-PI,
		PI
	)
	
#	var valid:bool = abs(dif) < deg2rad(fof)
#	return valid
	return abs(dif) < deg2rad(fof)

func handle_firing(_curTarget):
	do_fire(_curTarget)
			
func handle_burst_cooldown(delta):
	burstCooldown -= delta
	#print("burstDelay--")
#	if burstCooldown <= 0.0:
#		do_fire(curTarget)

func getAttackObject(_target = null):
	match type:
		1:
			return getBullet()
		2:
			return getMissile(_target)
		3:
			return getShell()
		4:
			return getBeam()
		6:
			return getRail()
		7:
			return getTorp(_target)
		8:
			return getMelee()
			
func applyRecoilFromWeaponFire():
	return
	if recoilForce:
		shooter.applyForce(-(recoilForce.rotated(global_rotation)))

func can_fire():
	if cooldown <= 0 or (bursting and burstCooldown <= 0.0):
		return true
	return false

func setPostFireCooldown():
	cooldown = rof
	
func do_fire(_target):
#	print("do_fire")
	if burst > 1:
		if !bursting:
			#print("can burst, not yet bursting")
			bursting = burst
			burstCooldown = 0.0
		
		if bursting && burstCooldown <= 0:
			bursting -= 1
			burstCooldown = burstDelay
			#print("bursting -1")
			#print("fire")
		else: return
	
	var projs = []
	
	for n in projNumber:
		projs.append(getAttackObject(_target))
	
	for i in len(projs):
		setProjRotation(projNumber, i, projs[i])
		setProjPosition(projNumber, i, projs[i])
		
		Globals.PROJCONT.add_child(projs[i])
		
	if burst == 1 or (burst > 1 and bursting == 0):
		setPostFireCooldown()
		
	doMuzzleEffect()
	eject_shell_casing()
	applyRecoilFromWeaponFire()
	emit_signal("hasFired")
	
func eject_shell_casing():
	pass
	
func setProjRotation(all, current, proj):
	var rota
	
	if linearDevi:
		rota = - deviation + ((deviation*2) / (all + -1) * current)
	else:
		rota = rand_range(-deviation, deviation)
	
	proj.rotation_degrees =  global_rotation_degrees + rota
	
func setProjPosition(all, current, proj):
	proj.global_position = $Muzzle.global_position
		
func getShotDeviation(projNumber, i):
	if linearDevi:
		return - deviation + ((deviation*2) / (projNumber+-1) * i)
	else:
		return rand_range(-deviation, deviation)
		
#		if linearDevi:
#			projs[i].rotation_degrees = global_rotation_degrees 
#		else:
#			projs[i].rotation_degrees = global_rotation_degrees + rand_range(-deviation, deviation)
	
		
func getLaunchOffset(all, current):
	return Vector2.ZERO

func getBullet():
#	var bullet
		
	var bullet = Globals.BULLET.instance()
#	match faction:
#		0:
#			bullet = Globals.BULLET_BLUE.instance()
#		1:
#			bullet = Globals.BULLET_RED.instance()

	bullet.constructProj(self)
	return bullet

func getMissile(target = null):
	return 
	
func getBeam():
	return
	
func getShell():
	return
	
func getTorp(target = null):
	return
	
func getMelee():
	return
	
func getRail():
	var rail = Globals.RAIL.instance()
	rail.constructProj(self)
#	rail.rotation_degrees = global_rotation_degrees + rand_range(-deviation, deviation)
	return rail
	
func is_in_range(pos):
	if speed == 0:
		return true
#	return global_position.distance_to(pos) < (max_range * 1.1)
	var dist = speed * lifetime * 1.1
	var range_sq = dist * dist

	return global_position.distance_squared_to(pos) < range_sq

func kill():
	if destroyed or indestructable: return
	destroyed = true
	doDisable()
	hide()
	set_physics_process(false)
	emit_signal("isDestroyed")
	if has_node("ControlNodes"):
		$ControlNodes.set_as_toplevel(false)
	disable_col_nodes()
	disable_all_timers()
		
func disable_all_timers():
	if has_node("TimerNodes"):
		for n in $TimerNodes.get_children():
			n.stop()

func fillQualityRows():
	subPanel_Stats.get_node("VBox/MC_Qual/Vbox/Label").text = str("-- ", getQualityAsString(), " --")
	match quality: 
		-2: subPanel_Stats.get_node("VBox/MC_Qual/Vbox/").set("modulate", Globals.ORANGE)
		-1: subPanel_Stats.get_node("VBox/MC_Qual/Vbox/").set("modulate", Globals.YELLOW) 
		0: subPanel_Stats.get_node("VBox/MC_Qual/Vbox/").set("modulate", Globals.WHITE)
		1: subPanel_Stats.get_node("VBox/MC_Qual/Vbox/").set("modulate", Globals.LIGHTGREEN)
		2: subPanel_Stats.get_node("VBox/MC_Qual/Vbox/").set("modulate", Globals.GREEN)

	for mod in mods:
		for n in mod.hits:
			var newEntry = subPanel_Stats.get_node("VBox/MC_Qual/Vbox/Label").duplicate()
			subPanel_Stats.get_node("VBox/MC_Qual/Vbox").add_child(newEntry)
			newEntry.show()
			newEntry.text = str(getModString(mod))
			
func getModString(mod):
	var string = ""
	for n in mod.mods:
		if n.type == "flat":
			if n.effect > 0:
				string += str(n.prop, " (+", n.effect, ")")
			else:
				string += str(n.prop, " (", n.effect, ")")
		elif n.type == "pct":
			string += str(n.prop, " (x", n.effect, ")")
		string += str("\n")
	
	string = string.left(len(string)-1)
	return string
	

func fillStatsRows():
	subPanel_Stats.addEntry("Cooldown", rof)
	subPanel_Stats.addEntry("Projs / Burst", str(burst, " x ", projNumber))
	subPanel_Stats.addEntry("Velocity", speed)
	subPanel_Stats.addEntry("Damage", str(minDmg, " - ", maxDmg))
	subPanel_Stats.addEntry("Deviation", deviation)
	
func initQuality():
	setQualityLevel()
	setQualityMods()
	applyQualityMods()
	
func setQualityLevel():
#	print(display)
	var outcomes = [-2, -1, 0, 1, 2]
	var treshold = [2, 5, 15, 18, 19]
	var roll = Globals.rng.randi_range(1, treshold[len(treshold)-1])
	roll = 19
	
	for i in len(treshold):
		if roll <= treshold[i]:
			quality = outcomes[i]
#			print("roll: ", roll)
#			print("<= ", treshold[i], ", hence ", quality)
			return
	return
	
func getQualityAsString():
	match quality:
		-10: return "Average quality"
		-2: return "Battered quality"
		-1: return "Poor quality"
		0: return "Average quality"
		1: return "Good quality"
		2: return "Outstanding quality"
		
func setQualityMods():
	if quality == 0: return
	
	#print(display)
	var pointsRemain = quality
	#print(pointsRemain)
	var possibilites = Globals.getPossibleWeaponMods(type)
	var totalWeight:int = 0
	#print(totalWeight)
	
	for entry in possibilites:
		totalWeight += entry.weight
		
	while pointsRemain != 0:
		var canSpend = false
		for entry in possibilites:
			if ((pointsRemain < 0 and entry.cost < 0) or (pointsRemain > 0 and entry.cost > 0)):
				canSpend = true
				break
		if not canSpend:
			break
		
		#print("top pointsRemain: ", pointsRemain)
		var dice = Globals.rng.randi_range(0, totalWeight)
		var current = dice
		#print("totalWeight: ", totalWeight)
		#print("rolled ", dice)
		
		for entry in possibilites:
#			if current > entry.weight or entry.cost > pointsRemain:
			if current > entry.weight or (pointsRemain < 0 and entry.cost > 0) or (pointsRemain > 0 and entry.cost < 0):
				current -= entry.weight
			elif (pointsRemain < 0 and entry.cost < pointsRemain) or (pointsRemain > 0 and entry.cost > pointsRemain):
				current -= entry.weight
			else:
				#print("picking ", entry.name)
				#entry.amount += 1
				pointsRemain -= entry.cost
				#print("pointsRemain: ", pointsRemain)
				entry.hits += 1
				#entry.cost += 1
				#base.display += str(entry.name, ";")
				break
	
	for entry in possibilites:
		if entry.hits:
			mods.append(entry)
	
func applyQualityMods():
	for entry in mods:
		for hit in entry.hits:
			for mod in entry.mods:
				match mod.type:
					"flat":
						self[mod.prop] += mod.effect
					"pct":
						self[mod.prop] *= mod.effect

	rof = stepify(rof, 0.01)
	speed = round(speed)
	
func init_cooldown_debug_label():
	var node = Globals.TEXT_LABEL.instance()
	node.hide()
	node.name = "rem_cooldown_label"
	node.offset = Vector2(0, max(40, texDim.y + 10))
	node.init_text_label_string(float(0.00))
	has_ControlNodes = true
	$ControlNodes.set_as_toplevel(true)
	$ControlNodes.add_child(node)

func canToggle():
	return true

func canBeUnselected():
	return true
	
func canBeSelected():
	return true
		
func doDisable():
#	print(display, ", faction: ", faction, " doDisable")
	$Aim.hide()
	active = false
	cooldown = rof
	update_cooldown_ui_nodes()
	check_init_aimdebug()
#	set_physics_process(false)

func doEnable():
#	print(display, ", faction: ", faction, " doEnable")
	if forcedDisabled:
		return
	if faction == 0 or (faction != 0 and type == 6):
		$Aim.show()
			
	active = true
	check_init_aimdebug()
#	set_physics_process(true)
	
func doUnselect():
#	print("_____", display, " doUnselect")
	if canBeUnselected():
		isSelected = false
		if UI_node != null:
			UI_node.get_node("PC").theme_type_variation = "Panel_Inner"
			subPanel_Stats.get_node("Timer").stop()
			subPanel_Stats.get_node("Tween").stop_all()
			subPanel_Stats.set("modulate", Color(1, 1, 1, 1))
			subPanel_Stats.hide()
		doDisable()
		
func doSelect():
#	print("_____", display, " doSelect")
	if UI_node != null:
		UI_node.get_node("PC").theme_type_variation = "panel_magenta_border"
	if Globals.isPaused:
		subPanel_Stats.show()
	else:
		subPanel_Stats.showandfadeout()
	isSelected = true
	doEnable()
		
func _on_LOOTNODE_mouseclick(event, lootnode):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		print("_on_LOOTNODE_mouseclick: ", display)
		Globals.curScene.get_node("UI/LootNodes").remove_child(full_ui_box)
		Globals.PLAYER.getActiveWeapon().doUnselect()
		Globals.PLAYER.addWeapon(self)
		Globals.PLAYER.active_weapon_index = Globals.PLAYER.get_node("Mounts/A").get_child_count()-1
		Globals.PLAYER.getActiveWeapon().doSelect()

func getIconContainer():
	var node = Globals.WEAPONENTRYCONT.instance()
	node.get_node("PC/VB/HB").queue_free()
	node.get_node("PC/VB/Tex").texture = Globals.getTex(texture, 1)
	return node
	
func getMaxRange():
	match type:
		1: return max_range
		2: return max_range
		3: return speed
		4: return self.beamLength
		5: return 2000
		6: return max_range

func doMuzzleEffect():
	$Muzzle/AnimatedSprite.show()
	$Muzzle/AnimatedSprite.frame = 0
	$Muzzle/AnimatedSprite.play()

func _on_AnimatedSprite_animation_finished():
	$Muzzle/AnimatedSprite.stop()
	$Muzzle/AnimatedSprite.hide()

func drawAimVector():
	var targetUp = Vector2.ZERO
	var targetDown = Vector2.ZERO
	
	var close = 200
	targetUp = Vector2(close, 0).rotated(deg2rad(deviation))
	targetDown = Vector2(close, 0).rotated(deg2rad(-deviation))
	$Aim/AimA.points[0] = targetUp
	$Aim/AimA.points[1] = targetDown
	
	var mid = 450
	targetUp = Vector2(mid, 0).rotated(deg2rad(deviation))
	targetDown = Vector2(mid, 0).rotated(deg2rad(-deviation))
	$Aim/AimB.points[0] = targetUp
	$Aim/AimB.points[1] = targetDown

func makeInvisible():
	$Sprites/Main.visible = false
	$Muzzle.position = Vector2(10, 0)
	
func get_class():
	return "Weapon_Base"

func has_active_omni_shield():
	return false
