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
var dmgType:int
var deviation:int
var texture
var turnrate:float

var canRotate = true

var shooter = null
var active = false
var usable = true

#var arc = Vector2()

var cooldown = 0
var bursting = 0
var burstDelay = 0.3

var fof = 3

var display:String
var notes:String

var time:float
var recoilForce = Vector2.ZERO
var impactForce = Vector2.ZERO

var anchor: Vector2# = Vector2.RIGHT.rotated(rotation)
var current_rot: Vector2#= anchor
var maximum_rotation: float# = PI / 6.0 # 30

func _ready():
#	print("_ready weapon BASE #", id, "__", display, "___", $Sprite.scale)
	
	isWeapon = true
	active = true
	cooldown = 0
	
	setRecoilForce()
	set_physics_process(true)
	
func _physics_process(_delta):
	cooldown = max(cooldown - _delta, 0.0)
	if isInActiveBurst():
		handleBursting(_delta)
	setWeaponPanelCooldown()

func constructNew(props):
#	print(props.display)
	for key in props:
		var value = props[key]
		if key in self:
			self[key] = value
	
	cooldown = props.rof
	
func setRecoilForce():
	
	recoilForce = Vector2(round(pow((minDmg+maxDmg)*speed, 0.6)), 0)
	print(display, ": recoil: ", recoilForce)
	return
	
	match type:
		1: #bull
			recoilForce = Vector2(round(pow(((minDmg+maxDmg)*speed)/10, 1.1)), 0)
#	recoil.x = 0
	
		
func setWeaponPanelCooldown():
	if UI_node == null: return
	UI_node.get_node("CC/PC/CDProgress").value = cooldown/rof*100
		
func get_class():
	return "Weapon"
		
func isInActiveBurst():
	if burst > 1 && bursting:
		return true
	return false

func handleFiring():
	if not canFire(): return
	
	var angleToTarget = rad2deg(curTarget.global_position.angle_to_point(global_position))
#	var dif = angleToTarget - global_rotation_degrees
#	print("dif: ", abs(round(dif)))
	if abs(round(angleToTarget - global_rotation_degrees)) == 360 or abs(angleToTarget - global_rotation_degrees) < fof:
		doFire(curTarget)
			
func handleBursting(delta):
	cooldown = 0
	burstDelay -= delta
	#print("burstDelay--")
	if burstDelay <= 0:
		doFire(curTarget)

func getAttackObject(target = null):
	match type:
		1:
			return getBullet()
		2:
			return getMissile(target)
		3:
			return getShell()
		4:
			return getBeam()
		6:
			return getRail()

func canFire():
	#if shotInstance: return true
	#print(cooldown)
	if not usable or cooldown > 0: 
		#print("can NOT fire!")
		return false
	#print("can fire!")
	return true
	
func doFire(_target):
	if burst > 1:
		if !bursting:
			#print("can burst, not yet bursting")
			bursting = burst
			burstDelay = 0
		
		if bursting && burstDelay <= 0:
			bursting -= 1
			burstDelay = 0.1
			#print("bursting -1")
			#print("fire")
		else: return
		
	cooldown = rof
	if recoilForce:
		shooter.applyForce(-(recoilForce.rotated(global_rotation)))
	
	for n in projNumber:
		#print("proj: ", n)
		var proj = getAttackObject(curTarget)
		proj.impactForce = recoilForce
		#var devi = Globals.rng.randi_range(-deviation, deviation)
		var devi = rand_range(-deviation, deviation)
		#print("devi: ", devi)
		proj.rotation_degrees = global_rotation_degrees + devi
		proj.global_position = $Muzzle.global_position
		Globals.curScene.get_node("Projectiles").add_child(proj)

func getBullet():
	var bullet
		
	match faction:
		0:
			bullet = Globals.BULLET_BLUE.instance()
		1:
			bullet = Globals.BULLET_RED.instance()

	bullet.constructNew(self)
	return bullet

func getMissile(target = null):
	return 
	
func getBeam():
	return
	
func getShell():
	return
	
func getRail():
	var rail = Globals.RAIL.instance()
#	rail.construct(faction, dmgType, speed, minDmg, maxDmg, impactForce, projSize)
	rail.constructNew(self)
	return rail
	
func isInRange(pos):
	if speed == 0: return true
	return global_position.distance_to(pos) < (speed * 2)

func weaponHasValidTarget():
#	print("weaponHasValidTarget on ", display, " #", id)
	if locked and curTarget != null:
		return !curTarget.destroyed
	if not is_instance_valid(curTarget) or curTarget.destroyed == true or curTarget.ready == false: return false
	if not isInRange(curTarget.global_position):
		#print(display, " to ", target.display, " dist > speed x2 = illegal target")
		return false
	if not isInArc(global_position.direction_to(curTarget.global_position)): 
		return false
	return true

func setWeaponTarget(allTargets):
	var targets = Array()
	for n in allTargets:
		if not n.isLegalTarget(): continue
		if not isInRange(n.global_position):
			continue
			
		var vec = global_position.direction_to(n.global_position)
		#print(vec)
		#var angle = vec.angle()
		
		#var angle = rad2deg(global_position.angle_to(n.global_position))
		
		if not isInArc(vec):
			continue
		
		targets.append(n)
	
	curTarget = Globals.getRandomEntry(targets)
	
func isInArc(vec):
	if maximum_rotation == PI: return true
#	print(owner.global_rotation_degrees)
	var from = anchor.rotated(-maximum_rotation + owner.global_rotation)
	var to = anchor.rotated(maximum_rotation + owner.global_rotation)
#	print(rad2deg(from.angle()), " - ",  rad2deg(to.angle()))
	if ((from.y * vec.x - from.x * vec.y) * (from.y * to.x - from.x * to.y) >= 0 && (to.y * vec.x - to.x * vec.y) * (to.y * from.x - to.x * from.y) >= 0):
#		print("in Arc!")
		return true
#	print("not in Arc!")
	return false

func doTrackTarget(_target, _delta):
	if canRotate == false: return
	if curTarget == null or not is_instance_valid(curTarget): return
	var change = get_angle_to(curTarget.global_position)
	if abs(change) < 0.01: return
	
	change = clamp(change, -turnrate, turnrate)
	
	var candidate = current_rot.rotated(change)
#	print(candidate)
	
	if abs(anchor.angle_to(candidate)) < maximum_rotation:
		current_rot = candidate
		rotation = current_rot.angle()

func looking_at(trans, pos):
	var x : Vector2 = (pos - trans.origin)
	var angle : float = atan2(x.y, x.x)
	return Transform2D(angle, trans.origin)

func kill():
	if destroyed or indestructable: return
	destroyed = true
	hide()
	set_physics_process(false)
	emit_signal("isDestroyed")
	
func getStatsPanel():
	var statsPanel = load("res://ui/PanelItemStats.tscn").instance()
	statsPanel.rect_position = Vector2(0, 0)
	statsPanel.get_node("VBox/MC_Title/Label").text = str(display)
	statsPanel.get_node("VBox/MC_Desc/Label").text = str(desc)
	
	fillQualityRows(statsPanel)
	fillStatsRows(statsPanel)
	return statsPanel

func fillQualityRows(statsPanel):
	statsPanel.get_node("VBox/MC_Qual/Vbox/Label").text = str("-- ", getQualityAsString(), " --")
	match quality: 
		-2: statsPanel.get_node("VBox/MC_Qual/Vbox/").set("modulate", "e92c00")
		-1: statsPanel.get_node("VBox/MC_Qual/Vbox/").set("modulate", "ffa100")
		1: statsPanel.get_node("VBox/MC_Qual/Vbox/").set("modulate", "bbe900")
		2: statsPanel.get_node("VBox/MC_Qual/Vbox/").set("modulate", "2cff00")

	for mod in mods:
		for n in mod.hits:
			var newEntry = statsPanel.get_node("VBox/MC_Qual/Vbox/Label").duplicate() 
			statsPanel.get_node("VBox/MC_Qual/Vbox").add_child(newEntry)
			newEntry.show()
			newEntry.text = str(mod.name)
	return statsPanel

func fillStatsRows(statsPanel):
	statsPanel.addEntry("Cooldown", rof)
	statsPanel.addEntry("Projs / Burst", str(burst, " x ", projNumber))
	statsPanel.addEntry("Velocity", speed)
	statsPanel.addEntry("Damage", str(minDmg, " - ", maxDmg))
	statsPanel.addEntry("Deviation", deviation)
	return statsPanel
	
func initQuality():
	setQualityLevel()
	setQualityMods()
	applyQualityMods()
	
func setQualityLevel():
#	print(display)
	var outcomes = [-2, -1, 0, 1, 2]
	var treshold = [2, 5, 15, 18, 19]
	var roll = Globals.rng.randi_range(1, treshold[len(treshold)-1])
	
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

func canToggle():
	return true
		
func toggle():
	active = !active
	if active:
#		for n in UI_node.get_children():
#			print(n.name)
		UI_node.get_node("CC/PC").add_stylebox_override("panel", Globals.RED)
		set_physics_process(true)
		if Globals.isPaused:
			subPanel_Stats.show()
		else:
			subPanel_Stats.showandfadeout()
	else: 
		subPanel_Stats.hide()
		UI_node.get_node("CC/PC").add_stylebox_override("panel", Globals.BLACK)
		set_physics_process(false)
		subPanel_Stats.get_node("Timer").stop()
		subPanel_Stats.get_node("Tween").stop_all()
		subPanel_Stats.set("modulate", Color(1, 1, 1, 1))
		subPanel_Stats.hide()
		
func _on_ICONPANEL_mouseclick(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		print("_on_ICONPANEL_mouseclick: ", display)
		Globals.curScene.get_node("UI/LootNodes").remove_child(full_ui_box)
#		$Sprite.material.set_shader_param("width", 0.0)
#		UI_node.get_node("CC/PC").add_stylebox_override("panel", Globals.BLACK)
		Globals.PLAYER.getActiveWeapon().toggle()
		Globals.PLAYER.addWeapon(self)
		Globals.PLAYER.aWeapon = Globals.PLAYER.weapons.size()-1
		toggle()

func getIconContainer():
	var node = Globals.WEAPONENTRYCONT.instance()
	node.get_node("CC/PC/VB/HB").queue_free()
	node.get_node("CC/PC/VB/Tex").texture = Globals.getTex(texture, 1)
	return node
	
func disableCollisionNodes():
	return
	
func doDisable():
	usable = false
	active = false
	UI_node.get_node("CC/PC").add_stylebox_override("panel", Globals.BLACK)

func doEnable():
	usable = true
	
func doInitUI():
	if full_ui_box == null:
		full_ui_box = get_full_ui_box()
		UI_node = full_ui_box.get_node("Vbox/Core")
		subPanel_Stats = full_ui_box.get_node("Vbox/PanelItemStats")
