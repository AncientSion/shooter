extends Node2D
class_name Base_Entity

onready var player = Globals.PLAYER

var texDim

var targets = []
var curTarget = null
var faction:int
var id = Globals.getId()

signal damageTaken
signal isDestroyed
signal objectiveDestroyed
signal hasWarpedIn
signal hasWarpedOut

var smoke:int
var maxSmoke:int
var destroyed = false
var isTarget = false
var indestructable = false
var real = true
var isObstacle = false
var locked = false
var canChangeBehavior = true

var healthbar = null
var healthlabel = null
var shieldbar = null
var shieldlabel = null
var lifetimelabel = null
var debug_ui_node = null
var UI_node = null
var full_ui_box = null

var isPlayer:bool = false
var isWeapon:bool = false
var isWarping:bool = false

var health:int
var mass:float
export var maxHealth:int
var shield = 0
export var maxShield = 0
export var armor:int = 0
export var minSpeed:int = 0
export var speed:int = 0
export var thrust:int = 0
export var lootValue:int = 0
var crashHeading:int

var lifetime:float = 0.0
var quality = -10
var effects = []
var mods = []

var ramDmg:int = 0
var isRamming = false
var rammings = []

var desc:String = ""
var dmgZones = {"DmgNormal": 1, "DmgWeak": 2, "DmgStrong": 0.5, "Shield": 1}

var subPanel_Stats = null

func _ready():
#	print("_ready Base_Entity ", self.display)
	texDim = Vector2($Sprite.texture.get_width() * $Sprite.scale.x, $Sprite.texture.get_height() * $Sprite.scale.y)
	setStats()
	setMass()
	setRamDamage()
	
	if has_node("ColNodes"):
		connect("damageTaken", self, "on_damage_taken")
		connectHurtBoxes()
	if has_node("ControlNodes"):
		$ControlNodes.set_as_toplevel(true)
	if has_node("Jump"):
		$Jump.set_as_toplevel(true)
		
func _physics_process(_delta):
	handleControlNodes()
	processRamming()
	
func connectHurtBoxes():
	for n in $ColNodes.get_children():
		n.connect("area_entered", self, str("_on_", n.name, "_area_entered"))
	for n in $ColNodes.get_children():
		n.connect("area_exited", self, str("_on_area_exited"))
	
func doInit():
	return
	
func setStats():
	return
	
func setMass():
	return

func _draw():
	if isTarget == false: return
	draw_rect(Rect2(-texDim.x, -texDim.y, texDim.x*2, texDim.y*2), Color(1, 0, 0, 0.7), false, 3)
	draw_line(Vector2(-texDim.x*1.3, 0), Vector2(texDim.x*1.3, 0), Color(1, 0, 0, 0.7), 3, false)
	draw_line(Vector2(0, -texDim.y*1.3), Vector2(0, texDim.y*1.3), Color(1, 0, 0, 0.71), 3, false)

func handleControlNodes():
	return
	
func setRamDamage():
	pass
	
#
#func constructNew(weapon):
#	faction = weapon.faction
#	dmgType = weapon.dmgType
#	speed = weapon.speed
#	minDmg = weapon.minDmg
#	maxDmg = weapon.maxDmg
#	aoe = weapon.aoe
#	lifetime = weapon.lifetime
#	projSize = weapon.projSize
#
#	type = 1
#	scale = Vector2(weapon.projSize, weapon.projSize)	

func getRamDamage():
#	return false
	var ramBullet = Globals.BULLET_BLUE.instance()
	Globals.curScene.get_node("Refs").add_child(ramBullet)
	ramBullet.minDmg = 5
	ramBullet.maxDmg = 7
	var effect = (ramBullet.minDmg + ramBullet.maxDmg) * self.velocity.length() * mass * 2
	ramBullet.impactForce = -Vector2(round(pow(effect, 0.6)), 0)
	return ramBullet
	
func processRamming():
	if not len(rammings):
		return
#	print("processRamming, scope ", self.display, ", #", self.id)
	for n in rammings:
		n.dmgCooldown -= 1
		if n.dmgCooldown == 0:
			n.dmgCooldown = 20
			
			print("processing ramming incoming from: ", n.rammedByDisplay, " #", n.rammedById, ", frame: ", Globals.frameCounter)
			print("MY position: ", global_position)
			print("rammed by position: ", n.rammingArea.owner.global_position)
#			print("own speed: ", self.velocity, "___", self.velocity.length())
#			print("other speed: ", n.rammingArea.owner.velocity ,"____", n.rammingArea.owner.velocity.length())
			
#func construct(init_faction, init_dmgType, init_speed, init_minDmg, init_maxDmg, init_aoe, init_lifetime, init_impactForce, init_projSize, init_shooter = false):
	
#			Globals.curScene.get_node("Refs").add_child(ramBullet)
#			ramBullet.construct(0, 0, 0, ramDmg, floor(ramDmg*1.5), 0, 0, Vector2(0, 0), 1)
			
			var ramBullet = getRamDamage()
			if ramBullet:
				ramBullet.set_physics_process(false)
				ramBullet.disableCollisionNodes()
				ramBullet.hide()
				
				ramBullet.position = global_position
				
				var a = (global_position - n.rammingArea.owner.global_position).angle()
				
#				var b = rad2deg(global_position.angle_to(n.rammingArea.owner.global_position))
				ramBullet.velocity = Vector2(1, 0).rotated(a)
				print(ramBullet.impactForce)
				
				n.rammingArea.owner.takeDamage(ramBullet, 1)
				ramBullet.queue_free()
			
func markAsTarget():
	return
	isTarget = true
	update()
	
func setCollisionTo(node):
	var colShape = CollisionShape2D.new()
	colShape.shape = RectangleShape2D.new()
	$ColNodes/DmgNormal.add_child(colShape)

	var x = get_node(node).texture.get_width() * get_node(node).scale.x
	var y = get_node(node).texture.get_height() * get_node(node).scale.y
	colShape.shape.extents = Vector2(x/2, y/2)
	
	$Sprite.offset = Vector2(0, 0)
	$ColNodes/DmgNormal.get_child(0).disabled = true
	
func makeClickable(node):
	$ColNodes/DmgNormal.connect("input_event", self, str(node.name.to_lower(), "_on_input_event"))
	
func sprite_on_input_event(_viewport, event, _shape_idx):
	if  event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		print("sprite click")
		
func icon_on_input_event(_viewport, event, _shape_idx):
	if  event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
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
	$Sprite.material.set_shader_param("width", 3.0)
	
func sprite_on_mouse_exited():
#	print("sprite out")
	$Sprite.material.set_shader_param("width", 0.0)
	
func icon_on_mouse_entered():
#	print("icon in")
	$Icon.material.set_shader_param("width", 3.0)
	
func icon_on_mouse_exited():
#	print("icon out")
	$Icon.material.set_shader_param("width", 0.0)

func takeDamage(entity, dmgMulti):
#	print("takeDamage")
	if destroyed: return 
	if indestructable: return
	
	var minDmg = entity.minDmg * dmgMulti
	var maxDmg = entity.maxDmg * dmgMulti
	var dmgType = entity.dmgType
	var pos = entity.getPointOfImpact(self)
	var angle = entity.getAttackAngle(self)
	
	var impactForce = entity.impactForce / mass
	print("impacting force: ", impactForce)
	applyForce(-(entity.impactForce).rotated(angle))
	
	var totalDmg = Globals.rng.randi_range(minDmg, maxDmg)
	var remDmg = totalDmg
	var shieldBefore = shield
	
	#print(self.display, " totalDmg: ", totalDmg)
	
	if shield > 0:
		#print("shield > 0")
		shield -= remDmg
		#print("taking shield ", remDmg)
		#print("shield left ", shield)
		remDmg = 0
		if shield < 0:
			##print("shield < 0")
			remDmg = -shield
			#print("remDmg: ", remDmg)
			shield = 0
			#print("shield = 0")
			
	if remDmg:
		remDmg = max(0, remDmg - self.armor)
#		print("health dmg ", remDmg)
		health -= remDmg
		
	var shieldDmgTaken = shieldBefore - shield
	
	if shieldDmgTaken:
		handleShieldDamage(shieldDmgTaken, pos, angle)
	if remDmg:
		handleHullDamage(remDmg, pos, angle)
	emit_signal("damageTaken")

func applyForce(force):
	return
		
func handleShieldDamage(shieldDmgTaken, pos, angle):
	addShieldExplosion(shieldDmgTaken, pos, angle)
	var labelPos = pos + Vector2(0, -(texDim.y/2) -10)
	createFloatingLabel(shieldDmgTaken, labelPos, Vector2(0, -100), Color(0, 0, 1, 1))
	checkForTriggers("on_shield_damage")
	if shield <= 0:
		call_deferred("unpowerShield")

func handleHullDamage(remDmg, pos, angle):
	addHitExplosion(remDmg, pos, angle)
	var labelPos = global_position + Vector2(Globals.rng.randi_range(-25, 25), -(texDim.y/2) -10)
	createFloatingLabel(remDmg, labelPos, Vector2(0, -100), Color(1, 0, 0, 1))
	checkForTriggers("on_damage")
	
	if isPlayer:
		var trauma = remDmg/25.0
		Globals.curScene.get_node("CamA").add_trauma(trauma)
	else:
		checkHealthAfterDmg(remDmg)
	
func checkForTriggers(condition):
	return

func checkHealthAfterDmg(amount):
	#print("checkHealthAfterDmg ", get_class())
	if health <= 0:
		kill()
	elif smoke == 0 && health <= self.maxHealth / 2:
		smoke += 1
		addEffectNode(Globals.getSmokeNode(0.5))
	return false
	
func get_class():
	return "Base_Entity"
	
func addEffectNode(node):
	$EffectNodes.add_child(node)
	
func disableCollisionNodes():
	$ColNodes/DmgNormal.set("monitoring", false)
	$ColNodes/DmgNormal.set("monitorable", false)
	for n in $ColNodes/DmgNormal.get_children():
		n.disabled = true

func kill():
	if destroyed or indestructable: return
	#print("destroying: ", self.display)
	destroyed = true
	hide()
	set_physics_process(false)
	call_deferred("disableCollisionNodes")
		
	var amount = ceil((texDim.x + texDim.y) / 15)
	for n in amount:
		var explo = Globals.getExplo("basic", 6)
		var pos = Vector2(Globals.rng.randi_range(-texDim.x/2, texDim.x/2), Globals.rng.randi_range(-texDim.y/2, texDim.y/2))
		explo.position = global_position + pos
		Globals.curScene.get_node("Various").add_child(explo)
	
	if not smoke:
		addEffectNode(Globals.getSmokeNode(0.5))
		
	emit_signal("objectiveDestroyed")
	emit_signal("isDestroyed")
	call_deferred("createRessources")
	
	if debug_ui_node != null:
		debug_ui_node.queue_free()
	for n in $ControlNodes.get_children():
		n.hide()
	for n in $Debug.get_children():
		n.hide()
	$Debug/C/behav.hide()
	$Debug/C/stats.hide()
	
	#queue_free()

func createRessources():
	return
	
func addShieldBar():
	#print("addShieldBar on ", self.display)
	shieldbar = Globals.SHIELDBAR.instance()
	$ControlNodes.add_child(shieldbar)
	var bar = shieldbar.get_node("ProgressBar")
	bar.min_value = 0
	bar.max_value = round(self.maxShield)
	setShieldBarHealth()
	shieldbar.offset = Vector2(0, 40)
	
	if get_class() == "Weapon":
		shieldbar.rect_scale = Vector2(0.5, 0.5)
		shieldbar.get_child(0).percent_visible = false

func addHealthBar():
	print("addHealthBar on ", self.display)
	healthbar = Globals.HEALTHBAR.instance()
	$ControlNodes.add_child(healthbar)
	var bar = healthbar.get_node("ProgressBar")
	bar.min_value = 0
	bar.max_value = round(self.maxHealth)
	setHealthBarHealth()
	healthbar.offset = Vector2(0, texDim.y/2 + 60)
	
	if get_class() == "Weapon":
		healthbar.rect_scale = Vector2(0.5, 0.5)
		healthbar.get_child(0).percent_visible = false
	
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
	if healthlabel != null:
		setHealthLabelHealth()
	if shieldbar != null:
		setShieldBarHealth()
	if shieldlabel != null:
		setShieldLabelHealth()

func setHealthBarHealth():
	healthbar.get_node("ProgressBar").value = self.health
	
func setHealthLabelHealth():
	healthlabel.get_node("Label").text = str(round(self.health), " / ", self.maxHealth)
	
func setShieldBarHealth():
	shieldbar.get_node("ProgressBar").value = self.shield
	
func setShieldLabelHealth():
	shieldlabel.get_node("Label").text = str(round(self.shield), " / ", self.maxShield)
	
func canWarp():
	return false
	
func modify():
	pass
	
func getPointInsideTex():
#	var x = Globals.rng.randi_range(0, texDim.x/2) * Globals.getRandomEntry([-1, 1])
#	var y = Globals.rng.randi_range(0, texDim.y/2) * Globals.getRandomEntry([-1, 1])
#	return Vector2(x, y)

	var x: int
	var y: int
	var valid = false
	var tex = $Sprite.get_texture().get_data()
	tex.lock()
	
	while not valid:
#		print("looping!")
		x = Globals.rng.randi_range(0, texDim.x)
		y = Globals.rng.randi_range(0, texDim.y)
		var p = tex.get_pixel(x, y)
		if p[3] == 1:
			valid = true
#		print(p)
#	print("got a valid one")
	return Vector2((-texDim.x/2)+x, (-texDim.y/2)+y)
	
func makeInvisible():
	$Sprite.visible = false
	$Muzzle.position = Vector2(15, 0)
	
func makeUntargetable():
	indestructable = true
	$ColNodes/DmgNormal.monitoring = false
	$ColNodes/DmgNormal.monitorable = false
	$ColNodes/DmgNormal.visible = false
	for n in $ColNodes/DmgNormal.get_children():
		n.disabled = true

func _on_ICONPANEL_mouse_entered():
	#print("mouse in")
	UI_node.get_node("CC/PC").add_stylebox_override("panel", Globals.YELLOW)
	
func _on_ICONPANEL_mouse_exited():
	#print("mouse out")
	UI_node.get_node("CC/PC").add_stylebox_override("panel", Globals.BLACK)
	
func setFriendly():
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
	
func setHostile():
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
	
func setNeutral():
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
	
func createFloatingLabel(string, pos, vector, color):
	var dmg_label = Globals.DMG_LABEL.instance()
	Globals.curScene.get_node("Various").add_child(dmg_label)
	dmg_label.global_position = pos
	dmg_label.init_floating_number(string, vector, 2.5, PI/2, color)

func addHitExplosion(damage, pos, angle):
#	print(rad2deg(angle))
	var explo = Globals.getExplo("basic", damage)
	explo.position += pos
	explo.rotation = angle
	Globals.curScene.get_node("Various").add_child(explo)
	
func addShieldExplosion(damage, pos, angle):
	var explo = Globals.getExplo("shield", damage)
	explo.position += pos
	explo.rotation = angle
	Globals.curScene.get_node("Various").add_child(explo)

func _on_DmgWeak_area_entered(area):
#	print(area.owner.get_class(), " entering ", self.get_class(), ": WEAK")
	handleImpact(area, self.dmgZones["DmgWeak"])

func _on_DmgStrong_area_entered(area):
#	print(area.owner.get_class(), " entering ", self.get_class(), ": STRONG")
	handleImpact(area, self.dmgZones["DmgStrong"])
	
func _on_DmgNormal_area_entered(area):
#	print(area.name, " entering ", self.name)
#	print(area.owner.get_class(), " entering ", self.get_class(), ": NORMAL")
	handleImpact(area, self.dmgZones["DmgNormal"])
	
func _on_Shield_area_entered(area):
#	print(area.owner.get_class(), " entering ", self.get_class(), ": NORMAL")
	handleImpact(area, self.dmgZones["Shield"])
	
func _on_area_exited(area):
#	print(area.owner.get_class(), " EXIT ", self.get_class(), ": NORMAL")
	endRamming(area)

func handleImpact(area, dmgMulti):
#	ifww not area.owwwwwwner.ready: return
	if area.owner.canExplodeOnContact():
		area.owner.explode()
	else:
		if area.owner.is_in_group("isUnit") or area.owner.is_in_group("isMount") or area.owner.is_in_group("isShield"):
			initRamming(area)
		else:
			takeDamage(area.owner.getDamageObject(), dmgMulti)
			area.owner.postImpacting()
		
func initRamming(area):
	print("initRamming ram from ", area.owner.display, " hitting ", self.display, " on frame ", Globals.frameCounter)
	print(area.name)
	
	var dict = {
		"rammedById": area.owner.id,
		"rammedByDisplay": area.owner.display,
		"dmgCooldown": 1,
		"rammingArea": area,
		"initFrame": Globals.frameCounter
	}
	
	isRamming = true
	rammings.append(dict)
	
func endRamming(area):
	if not isRamming: return
#	print("endRamming")
	for n in rammings:
		if n.rammingArea == area:
			rammings.erase(n)
#			print("remove, break")
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
	
func getStatsPanel():
	return

func get_full_ui_box():
	var root = Control.new()
	root.name = "Control"
	root.set_h_size_flags(2)
	var cont = VBoxContainer.new()
	cont.name = "Vbox"
	cont.grow_horizontal = 2
	cont.grow_vertical = 1
	
	cont.add_child(getIconContainer())
	cont.add_child(getStatsPanel())
	
	root.add_child(cont)
	return root
	
