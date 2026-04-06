extends Node2D
class_name Base_Entity

onready var player = Globals.PLAYER

var texDim

var targetsArr = []
var curTarget = null
var faction:int
var id = Globals.getId()

signal damageTaken
signal isDestroyed
signal objectiveDestroyed
signal _has_warped_in
signal _has_warped_out

var smoke:int
var maxSmoke:int
var destroyed = false
var isTarget = false
var isProtect = false
var target_indicator:POI = null
var indestructable = false
var invul = false
var real = true
var isObstacle = false
var forcedLock = false

var healthbar = null
var missionhealthbar = null
var healthlabel = null
var shieldbar = null
var shieldlabel = null
var lifetimelabel = null
var debug_menu_row = null
var UI_node = null
var full_ui_box = null

var isPlayer:bool = false
var isWeapon:bool = false
var canWarp:bool = false
var isWarping:bool = false

export var health:int
var mass:float
var maxHealth:int
var armor:int = 0
var maxSpeed:int = 0
var minSpeed:int = 0
var enginePower:int = 0
var thrust:int = 0
var lootValue:int = 0

var lifetime:float = 0.0
var quality = -10
var result = []
var stock_result = []
var mods = []

var ramDmg:int = 0
var isRamming = false
var rammings = []

var desc:String = ""
var dmgZones = {"DmgNormal": 1, "DmgWeak": 2, "DmgStrong": 0.5, "Shield": 1}

var subPanel_Stats = null
var has_ControlNodes:bool = false
var recoilForce = Vector2.ZERO
var impactForce = Vector2.ZERO

func _ready():
	texDim = Vector2($Sprites/Main.texture.get_width() * $Sprites/Main.scale.x, $Sprites/Main.texture.get_height() * $Sprites/Main.scale.y)
	setStats()
	setMass()
	setRamDamage()
	
#	print("_ready: ", get_class())
#	print("_ready: ", self.display)
	
#	print(get_class())
#	if healthbar != null:
#		healthbar.offset = Vector2(0, texDim.y/2 + 60)
	if has_node("ColNodes"):
		connect("damageTaken", self, "on_damage_taken")
		connectHurtBoxes()
#	if has_node("ControlNodes"):
	if has_node("Jump"):
		$Jump.set_as_toplevel(true)
		
	check_controlnodes_top_level()

func check_controlnodes_top_level():
	if has_node("ControlNodes") and $ControlNodes.get_children():
		has_ControlNodes = true
		$ControlNodes.set_as_toplevel(true)
		
func _physics_process(_delta):
	if has_ControlNodes:
		handleControlNodes()
	processRamming()
	
func handleControlNodes():
	for n in $ControlNodes.get_children():
		n.rect_position = global_position + n.offset
	
func connectHurtBoxes():
	for n in $ColNodes.get_children():
		if n.name != "Hover":
			n.connect("area_entered", self, str("_on_", n.name, "_area_entered"))
#	for n in $ColNodes.get_children():
			n.connect("area_exited", self, str("_on_area_exited"))
	
func doInit():
	return
	
func setStats():
	return
	
func setMass():
	mass = 1.0

func _draw():
	if isTarget:
		draw_rect(Rect2(-texDim.x*0.75, -texDim.y*0.75, texDim.x*1.5, texDim.y*1.55), Color(1, 0, 0, 0.2))
	elif isProtect:
		draw_rect(Rect2(-texDim.x*0.75, -texDim.y*0.75, texDim.x*1.5, texDim.y*1.55), Color(0, 1, 0, 0.2))
	return
	
	draw_rect(Rect2(-texDim.x*0.75, -texDim.y*0.75, texDim.x*1.5, texDim.y*1.55), Color(1, 0, 0, 0.2))
	
#	draw_rect(Rect2(-texDim.x, -texDim.y, texDim.x*2, texDim.y*2), Color(1, 0, 0, 0.7), false, 3)
#	draw_line(Vector2(-texDim.x*1.3, 0), Vector2(texDim.x*1.3, 0), Color(1, 0, 0, 0.7), 3, false)
#	draw_line(Vector2(0, -texDim.y*1.3), Vector2(0, texDim.y*1.3), Color(1, 0, 0, 0.71), 3, false)

	
func setCollisionTo(node):
	var colShape = CollisionShape2D.new()
	colShape.shape = RectangleShape2D.new()
	$ColNodes/DmgNormal.add_child(colShape)

	var x = get_node(node).texture.get_width() * get_node(node).scale.x
	var y = get_node(node).texture.get_height() * get_node(node).scale.y
	colShape.shape.extents = Vector2(x/2, y/2)
	
	$Sprites/Main.offset = Vector2(0, 0)
	$ColNodes/DmgNormal.get_child(0).disabled = true
	
func makeClickable(node):
	$ColNodes/DmgNormal.connect("input_event", self, str(node.name.to_lower(), "_on_input_event"))
	
func sprite_on_input_event(_viewport, event, _shape_idx):
	if  event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		print("sprite click")
		
func icon_on_input_event(_viewport, event, _shape_idx):
	if  event is InputEventMouseButton and event.fssed and event.button_index == BUTTON_LEFT:
		print("icon click")

func makeHighlightable(node):
	$ColNodes/DmgNormal.connect("mouse_entered", self, str(node.name.to_lower(), "_on_mouse_entered"))
	$ColNodes/DmgNormal.connect("mouse_exited", self, str(node.name.to_lower(), "_on_mouse_exited"))
	var outline = load("res://styles/outline.shader")
	node.material = ShaderMaterial.new()
	node.material.shader = outline
	node.material.resource_local_to_scene = true
	node.material.set_shader_param("width", 0.0)
	node.material.set_shader_param("color", Color(1, 1, 0, 1))
	
func sprite_on_mouse_entered():
#	print("sprite in")
	$Sprites/Main.material.set_shader_param("width", 3.0)
	
func sprite_on_mouse_exited():
#	print("sprite out")
	$Sprites/Main.material.set_shader_param("width", 0.0)
	
func icon_on_mouse_entered():
#	print("icon in")
	$Icon.material.set_shader_param("width", 3.0)
	
func icon_on_mouse_exited():
#	print("icon out")
	$Icon.material.set_shader_param("width", 0.0)

func takeDamage(entity, totalDmg:int):
	
#	totalDmg *= 2
	#print("takeDamage scope: ", self.display, " #", self.id)
#	var minDmg:int = entity.minDmg * dmgMulti
#	var maxDmg:int = entity.maxDmg * dmgMulti
#	var totalDmg:int = Globals.rng.randi_range(minDmg, maxDmg)

	var pos = entity.getPointOfImpact(self)
	var angle = entity.getAttackAngle(self)
	
	applyForce(-(entity.impactForce).rotated(angle))
	
	if totalDmg > 0:
		var remDmg:int = max(0, totalDmg - self.armor)
		if remDmg > 0:
			handleHullDamage(remDmg, pos, angle)
			emit_signal("damageTaken")

func applyForce(_force):
	return
		
func updateShield():
	return
	
func handleHullDamage(remDmg, pos, angle):
	var labelPos = global_position + Vector2(Globals.rng.randi_range(-25, 25), -(texDim.y/2) -10)
	createFloatingLabel(remDmg, labelPos, Vector2(0, -100))
	addHitExplosion(remDmg, pos, angle)
	if invul or destroyed:
		return
	health -= remDmg
	checkForTriggers("on_damage")
	
		
	if isPlayer:
		var trauma = remDmg/25.0
		Globals.curScene.get_node("CamA").add_trauma(trauma)
	else:
		check_hp_post_dmg(remDmg)
	
func checkForTriggers(_condition):
	return

func check_hp_post_dmg(amount):
#	print("check_hp_post_dmg ", get_class())
	if health <= 0:
		kill()
	elif smoke == 0 && smoke < maxSmoke && health <= self.maxHealth / 2:
#	elif smoke == 0 && health <= self.maxHealth / 2:
		smoke += 1
		add_smoke_fx(Globals.getSmokeNode(0.5))
	return false
	
func get_class():
	return "Base_Entity"
	
func add_fire_smoke_fx(scale:float, delay:float):
	var pos = get_point_inside_tex()
	var node = Globals.getFireSmokeNode(scale)
	node.delay = delay
	node.position = pos
	$EffectNodes.add_child(node)
	
func add_exp_fire_smoke_fx(scale:float, delay:float):
	var pos = get_point_inside_tex()
	var explo = Globals.getExplo("radial", scale, delay)
	explo.position = pos
	$EffectNodes.add_child(explo)
	var node = Globals.getFireSmokeNode(scale, delay + 0.2)
	node.position = pos
	$EffectNodes.add_child(node)
	
func add_smoke_fx(node):
	node.position = get_point_inside_tex()
	$EffectNodes.add_child(node)
	
func disableCollisionNodes():
#	print(self.display, ": DISABLE collisions")
	call_deferred("next_frame_disableCollisionNodes")
	
func next_frame_disableCollisionNodes():
#	print("disabling ", self.display)
	for n in $ColNodes.get_children():
		n.set("monitoring", false)
		n.set("monitorable", false)
		for i in n.get_children():
			i.disabled = true
	
	if has_node("Sight"):
		$Sight.set("monitoring", false)
		$Sight.set("monitorable", false)
		for n in $Sight.get_children():
			n.disabled = true
				
	if has_node("Phys"):
		$Phys.set("monitoring", false)
		$Phys.set("monitorable", false)
		for n in $Phys.get_children():
			n.disabled = true
			
func enableCollisionNodes():
#	print(self.display, ": ENABLE collisions")
	call_deferred("next_frame_enableCollisionNodes")
			
func next_frame_enableCollisionNodes():
#	print("enabling ", self.display)
	for n in $ColNodes.get_children():
		n.set("monitoring", true)
		n.set("monitorable", true)
		for i in n.get_children():
			i.disabled = false
	
	if has_node("Sight"):
		$Sight.set("monitoring", true)
		$Sight.set("monitorable", true)
		for n in $Sight.get_children():
			n.disabled = false

	if has_node("Phys"):
		$Phys.set("monitoring", true)
		$Phys.set("monitorable", true)
		for n in $Phys.get_children():
			n.disabled = false

func kill():
	if isPlayer or destroyed or indestructable:
		return
		
	destroyed = true
	emit_signal("isDestroyed")
	emit_signal("objectiveDestroyed")
	call_deferred("create_currency")
	set_physics_process(false)
	$SM.enabled = false
	
	for n in $Mounts.get_children():
		n.kill()
		
	if has_node("Tween"):
		if $Tween.is_active(): 
			$Tween.stop_all()
			$Tween.remove_all()
	
	if has_node("TimerNodes"):
		if $TimerNodes.has_node("WarpOutTimer"):
			$TimerNodes/WarpOutTimer.stop()
			cancelWarpOut()
		
	for n in $ControlNodes.get_children():
		n.hide()
	for n in $EffectNodes.get_children():
		if n.delay > 0.0:
			n.set_physics_process(false)

	if debug_menu_row != null:
		mark_debug_menu_entry_as_killed()
	
	if isTarget:
		unmark_as_target()
	elif isProtect:
		unmark_as_protect()
		
	handle_kill_explos()

func handle_kill_explos():
	var amount = ceil((texDim.x + texDim.y) / 24)
#	print("killing ", self.display, ", explos: ", amount)
#	amount = 3
	var maxDelay:float
		
	for n in ceil(amount*1):
#		print("adding explo ", n)
#	for n in 1:
		var delay = rand_range(1.0, 4.2)
		maxDelay = max(maxDelay, delay)
		var scale = get_dmg_gfx_scale()
#		
		add_exp_fire_smoke_fx(scale, delay)
		
		
func mark_debug_menu_entry_as_killed():
	return
		
func cancelWarpOut():
	return 
	
func mark_as_target():
	isTarget = true
	update()
	Globals.add_poi_marker(self)
	
func unmark_as_target():
	isTarget = false
	update()
	Globals.remove_poi_marker(self)
	
func mark_as_protect():
	isProtect = true
	update()
	Globals.add_poi_marker(self)
	
func unmark_as_protect():
	isProtect = false
	update()
	Globals.remove_poi_marker(self)

func create_currency():
	return
	
func add_shield_bar():
	#print("add_shield_bar on ", self.display)
	shieldbar = Globals.SHIELDBAR.instance()
	shieldbar.offset = Vector2(0, 80)
	$ControlNodes.add_child(shieldbar)
	var bar = shieldbar.get_node("ProgressBar")
	bar.min_value = 0
	bar.max_value = round(self.maxShield)
	setShieldBarHealth()
	has_ControlNodes = true
	$ControlNodes.set_as_toplevel(true)

func add_health_bar():
#	print("add_health_bar on ", self.display)
	healthbar = Globals.HEALTHBAR.instance()
	$ControlNodes.add_child(healthbar)
	var bar = healthbar.get_node("ProgressBar")
	bar.min_value = 0
	bar.max_value = round(self.maxHealth)
	setHealthBarHealth()
	has_ControlNodes = true
	$ControlNodes.set_as_toplevel(true)
	
#	healthbar.rect_scale = Vector2(0.5, 0.5)
#	healthbar.offset.y += 60
#	healthbar.get_child(0).percent_visible = false

func scaleBar(bartype, targetScale):
	var target = get(bartype)
	target.rect_scale = Vector2(targetScale, targetScale)
#	target.offset.y *= targetScale
	if targetScale <= 0.5:
		target.get_child(0).percent_visible = false
	
func getMissionHealthBar():
#	print("getMissionHealthBar on ", self.display)
	healthbar = Globals.HEALTHBAR.instance()
	var bar = healthbar.get_node("ProgressBar")
	bar.min_value = 0
	bar.max_value = round(maxHealth)
	bar.value = round(health)
	return healthbar
	
func addHealthLabel():
	healthlabel = Globals.HEALTHLABEL.instance()
	$ControlNodes.add_child(healthlabel)
	setHealthLabelHealth()
	healthlabel.offset = Vector2(0, texDim.y/2 + 20)
	
func addShieldLabel():
	shieldlabel = Globals.HEALTHLABEL.instance()
	$ControlNodes.add_child(shieldlabel)
	setHealthLabelHealth()
	shieldlabel.offset = Vector2(0, texDim.y/2 + 20)
	
func on_damage_taken():
	if healthbar != null:
		setHealthBarHealth()
	if missionhealthbar != null:
		setmissionhealthbar()
	if healthlabel != null:
		setHealthLabelHealth()
	if shieldbar != null:
		setShieldBarHealth()
	if shieldlabel != null:
		setShieldLabelHealth()
	if not destroyed and debug_menu_row != null:
		debug_menu_row.get_node("hp/label").text = str(health, "/", maxHealth)

func setHealthBarHealth():
	healthbar.get_node("ProgressBar").value = self.health
	
func setmissionhealthbar():
	missionhealthbar.value = self.health
	
func setHealthLabelHealth():
	healthlabel.get_node("Label").text = str(round(self.health), " / ", self.maxHealth)
		
func setShieldBarHealth():
	if shieldbar == null:
		return
	if shieldbar is TextureProgress:
		shieldbar.value = self.shield
		shieldbar.max_value = self.maxShield
		if shieldbar.has_node("Value"):
			shieldbar.get_node("Value").text = str(round(self.shield), " / ", self.maxShield)
	else:
		shieldbar.get_node("ProgressBar").value = self.shield
		shieldbar.get_node("ProgressBar").max_value = self.maxShield
		if shieldbar.has_node("Value"):
			shieldbar.get_node("Value").text = str(round(self.shield), " / ", self.maxShield)
	
func dsetShieldBarHealthx():
	if shieldbar == null:
		return
	shieldbar.value = self.shield
	shieldbar.max_value = self.maxShield
	if shieldbar.has_node("Value"):
		shieldbar.get_node("Value").text = str(round(self.shield), " / ", self.maxShield)
		
func setShieldBarBreakTime(time_left):
	if shieldbar and shieldbar.has_node("Value"):
		shieldbar.get_node("Value").text = str("%.1f" % time_left)
	
func setShieldLabelHealth():
	shieldlabel.get_node("Label").text = str(round(self.shield), " / ", self.maxShield)
	
func modify():
	pass
	
	
#	texDim = Vector2($Sprites/Main.texture.get_width() * $Sprites/Main.scale.x, $Sprites/Main.texture.get_height() * $Sprites/Main.scale.y)
	
func get_point_inside_tex():
	var valid = false
	var tex = $Sprites/Main.get_texture().get_data()
	var dim = $Sprites/Main.get_texture().get_size()
	tex.lock()
	
	var tries:int = 0
	
	while not valid:
		tries += 1
#		print("looping!")
		var pos = Vector2(Globals.rng.randi_range(0, dim.x-1), Globals.rng.randi_range(0, dim.y-1))
#		print(pos)
		var p = tex.get_pixelv(pos)
		if p[3] == 1:
			pos *= $Sprites/Main.scale
			pos = Vector2((-texDim.x/2)+pos.x, (-texDim.y/2)+pos.y)
			return pos
		if tries >= 100:
			break
			
	
func makeInvisible():
	$Sprites.visible = false
	
func makeUntargetable():
	indestructable = true
	call_deferred("next_frame_disableCollisionNodes")

func _on_LOOTNODE_mouse_entered(node):
#	print("mouse in")
#	node.theme_type_variation = "panel_magenta_border"
#	return
	var new_stylebox_normal = node.get_stylebox("panel").duplicate()
#	new_stylebox_normal.border_color = Globals.MAGENTA
	new_stylebox_normal.bg_color = Globals.MAGENTA
	node.add_stylebox_override("panel", new_stylebox_normal)
#	
func _on_LOOTNODE_mouse_exited(node):
#	print("mouse out")
#	node.theme_type_variation = ""
#	return
	node.add_stylebox_override("panel", null)
	
func set_faction(factionID):
	faction = factionID
		
	if faction == 0:
		set_friendly()
	elif faction == 1:
		set_hostile()
	elif faction == 2:
		set_neutral()
	elif faction == 3:
		set_as_dummy()
	
func set_friendly():
	faction = 0
	if has_node("ColNodes"):
		for i in $ColNodes.get_children():
			i.set_collision_layer_bit(0, true)
			i.set_collision_mask_bit(1, true) #contact with enemy units
			i.set_collision_mask_bit(3, true) #contact with enemy projs
			
	if has_node("Phys"):
		$Phys.set_collision_layer_bit(4, true)
	if has_node("Sight"):
		$Sight.set_collision_mask_bit(4, true)
	if self.isPlayer:
		$ColNodes/DmgNormal.set_collision_layer_bit(6, true)
		
#	$Phys.set_collision_layer_bit(4, false)
#	$Phys.set_collision_layer_bit(6, false)
	
func set_hostile():
	faction = 1
	if has_node("ColNodes"):
		for i in $ColNodes.get_children():
			i.set_collision_layer_bit(1, true)
			i.set_collision_mask_bit(0, true) #contact with player unit
			i.set_collision_mask_bit(2, true) #contact with player projs
			
	if has_node("Phys"):
		$Phys.set_collision_layer_bit(4, true)
	if has_node("Sight"):
		$Sight.set_collision_mask_bit(4, true)
	
func set_neutral():
	faction = 2
	if has_node("ColNodes"):
		for i in $ColNodes.get_children():
			i.set_collision_layer_bit(0, true)
			i.set_collision_layer_bit(1, true)
			i.set_collision_mask_bit(2, true)
			i.set_collision_mask_bit(3, true)
			
	if has_node("Phys"):
		$Phys.set_collision_layer_bit(4, true)
#	if has_node("Sight"):
#		$Sight.set_collision_mask_bit(4, true)

func set_as_dummy():
	faction = 3
	if has_node("ColNodes"):
		for i in $ColNodes.get_children():
			i.set_collision_layer_bit(0, false)
			i.set_collision_mask_bit(0, false)
	
func createFloatingLabel(string, pos, vector, crit = false, color = null):
	var dmg_label = Globals.DMG_LABEL.instance()
	Globals.curScene.get_node("Various").add_child(dmg_label)
	dmg_label.global_position = pos
	dmg_label.init_floating_number(string, vector, 2.5, PI/2, crit, color)

func addHitExplosion(damage, pos, angle):
#	print(rad2deg(angle))
	var baseDmg = 8.0
	var scale:float  = sqrt(damage/baseDmg)
	var explo = Globals.getExplo("basic", scale)
	explo.position += pos
	explo.rotation = angle
	Globals.curScene.get_node("Various").add_child(explo)
	
func addShieldExplosion(damage, pos, angle):
	var baseDmg = 8.0
	var scale:float  = sqrt(damage/baseDmg)
	var explo = Globals.getExplo("shield", scale)
	explo.position += pos
	explo.rotation = angle
	Globals.curScene.get_node("Various").add_child(explo)

func _on_DmgWeak_area_entered(area):
#	print(area.owner.get_class(), "-", area.name, " entering ", self.get_class(), "/", name)
	handleImpact(area, self.dmgZones["DmgWeak"])

func _on_DmgStrong_area_entered(area):
#	print(area.owner.get_class(), "-", area.name, " entering ", self.get_class(), "/", name)
	handleImpact(area, self.dmgZones["DmgStrong"])
	
func _on_DmgNormal_area_entered(area):
#	print("Frame: ", Engine.get_idle_frames(), ", collision")
#	print(area.owner.get_class(), "-", area.name, " entering ", self.get_class(), "/", name)
	handleImpact(area, self.dmgZones["DmgNormal"])
	
func _on_Shield_area_entered(area):
#	print(area.owner.get_class(), "-", area.name, " entering ", self.get_class(), "/", name)
	handleImpact(area, self.dmgZones["Shield"])
	
func _on_area_exited(area):
#	print(area.owner.get_class(), " EXIT ", self.get_class(), ": NORMAL")
	endRamming(area)

func handleImpact(area, dmgMulti):
	if area.owner.canExplodeOnContact():
		area.owner.explode()
	else:
		if area.owner.is_in_group("isUnit") or area.owner.is_in_group("isMount") or area.owner.is_in_group("isShield"):
			initRamming(area)
		elif not destroyed and area.owner.display == "Boundary":
			killByCrash()
		else:
			var dmgObj = area.owner.getDamageObject()
			takeDamage(dmgObj, Globals.getRawDamage(dmgObj.minDmg, dmgObj.maxDmg, dmgMulti))
			area.owner.postImpacting()
		
func initRamming(area):
#	print("initRamming scope: ", self.display, " #", self.id, " being hit by: ", area.owner.display, " #", area.owner.id, " on frame: ", Engine.get_idle_frames())
	
	var dict = {
		"rammedById": area.owner.id,
		"rammedByDisplay": area.owner.display,
		"dmgCooldown": 1,
		"rammingArea": area,
		"initFrame": Engine.get_idle_frames(),
		"legal": true
	}
	
	if has_active_omni_shield() or area.owner.has_active_omni_shield():
		dict.legal = false
	
	isRamming = true
	rammings.append(dict)
	
func has_active_omni_shield():
	if is_in_group("isUnit") and $Mounts.get_children() and $Mounts/A.get_child(0).get_class() == "Weapon_Shield_Omni" and $Mounts/A.get_child(0).shield > 0:
#		print("active omni, making ram illegal")
		return true
	return false
	
func setRamDamage():
	pass
	
func processRamming():
	if not len(rammings):
		return
#	print("processRamming, scope ", self.display, ", #", self.id)
	for opp in rammings:
		if opp.legal == true:
			opp.dmgCooldown -= 1
			if opp.dmgCooldown == 0:
				opp.dmgCooldown = 20
#				print("processing ramming incoming from: ", opp.rammedByDisplay, " #", opp.rammedById, ", frame: ", Engine.get_idle_frames())
				processRamDamage(opp)
	#			print("rammed by position: ", n.rammingArea.owner.global_position)
	#			print("own speed: ", self.velocity, "___", self.velocity.length())
	#			print("other speed: ", n.rammingArea.owner.velocity ,"____", n.rammingArea.owner.velocity.length())

func processRamDamage(opp):
#	print("processRamDamage:", self.display, " position: ", global_position)
	var ramBullet = getRamDamage()
	if ramBullet:
		var a = (global_position - opp.rammingArea.owner.global_position).angle()
#		var b = rad2deg(global_position.angle_to(n.rammingArea.owner.global_position))
		ramBullet.velocity = Vector2(1, 0).rotated(a)
#		print("ram impactF: ", ramBullet.impactForce)
#		print("angle: ", round(rad2deg(a)))
		
		opp.rammingArea.owner.takeDamage(ramBullet, Globals.getRawDamage(ramBullet.minDmg, ramBullet.maxDmg, 1.0))
		ramBullet.queue_free()
		
func getRamDamage():
#	return false
	var ramBullet = Globals.BULLET.instance()
	Globals.curScene.get_node("Refs").add_child(ramBullet)
	ramBullet.minDmg = round(pow(mass, 0.4))
	ramBullet.maxDmg = round(ramBullet.minDmg * 1.3)
#	print("ramBullet from ", self.display, ": ", ramBullet.minDmg, " - ", ramBullet.maxDmg)
	ramBullet.set_physics_process(false)
	ramBullet.disableTriggerCollisionNodes()
	ramBullet.hide()
	ramBullet.position = global_position
#	var effect = (ramBullet.minDmg + ramBullet.maxDmg) * self.velocity.length() * mass
#	ramBullet.impactForce = Globals.getRecoilForce(ramBullet.minDmg, ramBullet.maxDmg, self.velocity.length()) * mass / 2
	return ramBullet
	
func killByCrash():
	return
	
func endRamming(area):
	if not isRamming: return
#	print("endRamming on:", self.display, " #", self.id)
	for n in rammings:
		if n.rammingArea == area:
			rammings.erase(n)
			print("endRamming-erasing ", n.rammedByDisplay, " #", n.rammedById, " on frame ", Engine.get_idle_frames())
			break
	if not len(rammings):
#		print("isRamming = false")
		isRamming = false
	
func canExplodeOnContact():
	return false
	
func postImpacting():
	return

func getIconContainer():
	return

func setStatsPanel():
	if subPanel_Stats == null:
		subPanel_Stats = load("res://ui/PanelItemStats.tscn").instance()
	subPanel_Stats.rect_position = Vector2(0, 0)
	subPanel_Stats.get_node("VBox/MC_Title/Label").text = str(self.display)
	subPanel_Stats.get_node("VBox/MC_Desc/Label").text = str(desc)
	
	fillQualityRows()
	fillStatsRows()

func fillQualityRows():
	pass
	
func fillStatsRows():
	pass
	
func doInitUI():
	if full_ui_box == null:
		set_full_ui_box()
		UI_node = full_ui_box.get_node("Vbox/Core")
		subPanel_Stats = full_ui_box.get_node("Vbox/PanelItemStats")

func set_full_ui_box():
	var root = PanelContainer.new()
	root.name = "PanelContainer_Loot"
	root.set_h_size_flags(3)
	var cont = VBoxContainer.new()
	cont.name = "Vbox"
	
	cont.add_child(getIconContainer())
	setStatsPanel()
	cont.add_child(subPanel_Stats)
	
	root.add_child(cont)
	full_ui_box = root

func enter_pause():
	if subPanel_Stats == null:
		return
	subPanel_Stats.get_node("Timer").stop()
	subPanel_Stats.get_node("Tween").stop_all()
	subPanel_Stats.set("modulate", Color(1, 1, 1, 1))
	
func leave_pause():
	if subPanel_Stats == null:
		return
	subPanel_Stats.set("modulate", Color(1, 1, 1, 1))
	subPanel_Stats.hide()

func enterBoundary():
	return

func exitBoundary():
	return
	
func get_dmg_gfx_scale():
	return 1
