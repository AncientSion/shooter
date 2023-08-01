extends Node2D
class_name Proj_Base

var velocity = Vector2.ZERO
var accel = Vector2.ZERO
var gravity_vec = Vector2.ZERO
var active = true
var lifetime: float

var speed:int
var dmgType:int
var minDmg:int
var maxDmg:int
var aoe:int = 0
var faction:int
var projSize:float
var projNumber:int
var shooter
var texDim = Vector2.ZERO
var impactForce = Vector2.ZERO
var type

var canExplode = false
var isExploding = false

func _ready():
	if has_node("Sprite"):
		texDim = Vector2($Sprite.texture.get_width() * $Sprite.scale.x, $Sprite.texture.get_height() * $Sprite.scale.y)

	if aoe != 0:
		canExplode = true
		var aoe_shape = CollisionShape2D.new()
		aoe_shape.name = "A"
		aoe_shape.shape = CircleShape2D.new()
		aoe_shape.shape.radius = aoe
		$ColNodes/AoeArea.add_child(aoe_shape)

	if faction == 0:
		setFriendly()
	elif faction == 1:
		setHostile()
	elif faction == 2:
		setNeutral()

	gravity_vec = Globals.BASEGRAVITY
	set_physics_process(true)

func _physics_process(delta):
	if lifetime > 0:
		lifetime -= delta
		if lifetime <= 0:
			on_lifetime_timeout()
		
		
	
func on_lifetime_timeout():
	match type:
		1:
			doFadeOut()
		2: 
			explode()
		4:
			doFadeOut()
		6:
			doFadeOut()
		
func doFadeOut():
	$Tween.interpolate_property(self, "modulate:a",
			1.0, 0.3, 0.5,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

	$Tween.start()
	yield($Tween, "tween_all_completed")
	explode()
	queue_free()
	
func explode():
	if not canExplode:
		return
	isExploding = true
	var explo
	if dmgType == 0:
		explo = Globals.EXPLO_00_01.instance()
	elif dmgType == 1:
		explo = Globals.EXPLO_01_01.instance()
	explo.position = global_position
	explo.get_node("AnimatedSprite").scale = Vector2(2.5*aoe/32, 2.5*aoe/32)
	explo.get_node("AnimatedSprite").play()
	Globals.curScene.get_node("Various").add_child(explo)
	doAreaAttack()
	active = false
		
func canExplodeOnContact():
	return canExplode
	
func setFriendly():
	faction = 0
	$ColNodes/DmgNormal.set_collision_layer_bit(2, true)
	$ColNodes/DmgNormal.set_collision_mask_bit(1, true)
	
	if has_node("ColNodes/AoeArea"):
		get_node("ColNodes/AoeArea").set_collision_layer_bit(2, true)
		get_node("ColNodes/AoeArea").set_collision_mask_bit(1, true)
	
func setHostile():
	faction = 1
	#print("setHostile")
	$ColNodes/DmgNormal.set_collision_layer_bit(3, true)
	$ColNodes/DmgNormal.set_collision_mask_bit(0, true)
	
	if has_node("ColNodes/AoeArea"):
		get_node("ColNodes/AoeArea").set_collision_layer_bit(3, true)
		get_node("ColNodes/AoeArea").set_collision_mask_bit(0, true)
	
func setNeutral():
	faction = 2
#	$ColNodes/DmgNormal.set_collision_layer_bit(0, true)
#	$ColNodes/DmgNormal.set_collision_layer_bit(1, true)
	$ColNodes/DmgNormal.set_collision_mask_bit(0, true)
	$ColNodes/DmgNormal.set_collision_mask_bit(1, true)
	
	if has_node("ColNodes/AoeArea"):
#		get_node("ColNodes/AoeArea").set_collision_layer_bit(3, true)
		get_node("ColNodes/AoeArea").set_collision_mask_bit(0, true)
		get_node("ColNodes/AoeArea").set_collision_mask_bit(1, true)
	
func getPointOfImpact(impactedEntity):
	return global_position
	
func getAttackAngle(impactedEntity):
#	return (global_position - impactedEntity.global_position).angle()
	if isExploding:
		return (global_position - impactedEntity.global_position).angle()
	else:
		return (velocity*-1).angle()
	
func disableCollisionNodes():
	$ColNodes/DmgNormal.set("monitoring", false)
	$ColNodes/DmgNormal.set("monitorable", false)
	for n in $ColNodes/DmgNormal.get_children():
		n.disabled = true
		
func doAreaAttack():
#		print("doAreaAttack from ", get_class(), " with AoE: ",$ColNodes/AoeArea/A.shape.radius, ", damage: ", minDmg, "-", maxDmg)
		var areas = $ColNodes/AoeArea.get_overlapping_areas()
#		print("targets: ", len(areas))
		for area in areas:
			print("hitting: ", area.owner.display)
			area.owner.takeDamage(self, area.owner.dmgZones[area.name])
#			area.owner.checkAggro(shooter)
		queue_free()

func postImpacting():
	queue_free()

func getDamageObject():
	return self
