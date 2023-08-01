extends Node2D
class_name Proj_Beam

var	dmgType:int
var velocity = Vector2.ZERO
var minDmg:int
var maxDmg:int
var faction:int
var beamLength:int
var beamWidth:int
var lifetime:float
var projNumber:int
var origin
var shooter

var texDim
var active = true

var isStatic = false
var isPiercing = false
var hits = 0
var maxHits = 3
var collide = Vector2.ZERO
var impactForce = Vector2.ZERO
var dmgCooldown = 15

var damaging = []
	
func constructNew(weapon):
	faction = weapon.faction
	dmgType = weapon.dmgType
	minDmg = weapon.minDmg
	maxDmg = weapon.maxDmg
	beamLength = weapon.beamLength
	beamWidth = weapon.beamWidth
	lifetime = weapon.lifetime
	projNumber = weapon.projNumber
	shooter = weapon.shooter
	origin = weapon
	
func _ready():
	texDim = Vector2.ZERO
	
	if faction == 0:
		setFriendly()
	elif faction == 1:
		setHostile()
	elif faction == 2:
		setNeutral()
	$RayNodes/A.cast_to = Vector2(beamLength, 0)
	$RayNodes/B.cast_to = Vector2(beamLength, 0)
	setBeamWidth()
	
func setFriendly():
	faction = 0
	$ColNodes/DmgNormal.set_collision_layer_bit(2, true)
	$ColNodes/DmgNormal.set_collision_mask_bit(1, true)
	$RayNodes/A.set_collision_mask_bit(1, true)
	$RayNodes/B.set_collision_mask_bit(1, true)
	
func setHostile():
	faction = 1
	#print("setHostile")
	$ColNodes/DmgNormal.set_collision_layer_bit(3, true)
	$ColNodes/DmgNormal.set_collision_mask_bit(0, true)
	$RayNodes/A.set_collision_mask_bit(0, true)
	$RayNodes/B.set_collision_mask_bit(0, true)
	
func setNeutral():
	faction = 2
	$ColNodes/DmgNormal.set_collision_layer_bit(0, true)
	$ColNodes/DmgNormal.set_collision_layer_bit(1, true)
	$ColNodes/DmgNormal.set_collision_mask_bit(2, true)
	$ColNodes/DmgNormal.set_collision_mask_bit(3, true)
	
func setBeamWidth():
	$BeamLinePos/Real.width = floor(beamWidth)
	$ColNodes/DmgNormal/ColShape.shape.extents.y = floor(beamWidth/2)
#	$ColNodes/DmgNormal/ColShape.shape.extents.x = floor(beamLength/2) + 5
#	$ColNodes/DmgNormal/ColShape.position.x = floor(beamLength/2) + 5
	
	$RayNodes/A.position.y = -beamWidth/2
	$RayNodes/B.position.y = beamWidth/2

func _physics_process(_delta):
	if lifetime > 0:
		lifetime -= _delta
		if lifetime <= 0:
			on_lifetime_timeout()
		
	#print("____physics_process beam")
	if not isStatic:
		if is_instance_valid(origin):
			global_position = origin.get_node("Muzzle").global_position
			rotation = origin.global_rotation
	
	collide = Vector2.ZERO
	var beamEnd = Vector2(beamLength, 0)
	
	var shift = Vector2(0, -beamWidth/2)
	for n in $RayNodes.get_children():
		shift *= -1
		if n.is_colliding():
			collide = n.get_collision_point()
#			collide.y += 4
#			print("ray node ", n.name, " with collision point ", collide)
			if not isPiercing: 
				beamEnd = (collide - global_position).rotated(-rotation)
				beamEnd += shift
#				print("beamend: ", beamEnd)
			break
		
	$ColNodes/DmgNormal/ColShape.shape.extents.x = floor(beamEnd.x/2) + 5
	$ColNodes/DmgNormal/ColShape.position.x = floor(beamEnd.x/2) + 5
	$BeamLinePos/Real.points[1] = beamEnd
	process_beam_damage()
#	queue_free()
	
func doBeamFadeIn():
#	return
	$BeamLinePos.scale.y = 0
	$Tween.interpolate_property($BeamLinePos, "modulate:a",
		0.0, 1.0, 1,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($BeamLinePos, "scale:y",
		0.0, 0.33, 1,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	
	$ColNodes/DmgNormal/ColShape.disabled = false
	
	$Tween.interpolate_property($BeamLinePos, "scale:y",
		0.33, 1.5, 0.5,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	$Tween.interpolate_property($BeamLinePos, "scale:y",
		1.5, 1.0, 0.5,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	
func initBeamSwipe():
	yield(get_tree().create_timer(3.0), "timeout")
#	$Tween.interpolate_property(self, "position:x",
#		global_position.x, global_position.x - 100, 4,
#		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(self, "rotation_degrees",
		rotation_degrees, rotation_degrees + 20, 2,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	doBeamFadeOut()

func doBeamFadeOut():
	$ColNodes/DmgNormal.monitoring = false
	$ColNodes/DmgNormal.monitorable = false
	$Tween.interpolate_property($BeamLinePos, "modulate:a",
		1.0, 0.0, 0.5,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($BeamLinePos, "scale:y",
		1.0, 0.0, 0.5,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	queue_free() 
	
func on_lifetime_timeout():
	doBeamFadeOut()

func _on_DmgNormal_area_entered(area):
#	print("_on_Beam_area_ENTRY ", area.get_parent().get_parent().display, ", area: ", area.name)
#	if not isPiercing and not damaging.empty(): return
	#$EffectNodes/Impact.emitting = true
	for n in damaging:
		if n.targetid == area.get_parent().get_parent().id:
			n.area = area
#			print("switching dmg area")
			return
			
	var target
	var targetid
	var dict = {
		"dmgCooldown" : 10,
		"area": area,
		"target": null,
		"dmgZone": area.name,
		"collider": Vector2.ZERO,#ray.get_collision_point(),
		"targetid": 0,
		"display": "",
	}
	
	if not isPiercing:
#		print("not piercing")
		dict.target = area.get_parent().get_parent()
		dict.targetid = dict.target.id
		dict.display = dict.target.display
		damaging.append(dict)
#		print("adding target ", dict.display, " #", dict.targetid)
	else:
#		print("piercing")
		for ray in $RayNodes.get_children():
			for n in damaging:
				ray.add_exception(n.area)
			ray.force_raycast_update()
			if ray.is_colliding():
				dict.target = area.get_parent().get_parent()
				dict.targetid = dict.target.id
				dict.display = dict.target.display
				var new = true
				for n in damaging:
					if n.targetid == dict.targetid:
						new = false
						break
				if new:
					damaging.append(dict)
#					print("adding target ", dict.display, " #", dict.targetid)
				
		for n in $RayNodes.get_children():
			n.clear_exceptions()

func _on_DmgNormal_area_exited(area):
#	print("_on_Beam_area_EXIT ", area.get_parent().get_parent().display, ", area: ", area.name)
	for n in damaging:
#		if n.area.id == area.get_parent().get_parent().id:
		if n.area == area:
			damaging.erase(n)
#			print("erase on exit")
			return

func setBeamImpactParticle(pos):
	var fuse = Globals.get("BEAM_IMPACT").instance()
	Globals.curScene.get_node("Various").add_child(fuse)
	fuse.emitting = true
	fuse.position = pos
	fuse.rotation = rotation
	fuse.process_material.emission_box_extents.y = floor(beamWidth * 0.7)

func process_beam_damage():
	if not damaging.size(): return

	for n in damaging:
		#print("process_beam_damage on: ", n.target.display, " cooldown at ", n.dmgCooldown)
		
		
		n.dmgCooldown += 1
		
		if n.dmgCooldown % 3 == 0:
			for ray in $RayNodes.get_children():
				ray.force_raycast_update()
				if ray.is_colliding():
					var collider = ray.get_collider()
					if collider.get_parent().get_parent().id == n.targetid:
						n.collider = ray.get_collision_point()
						break
			setBeamImpactParticle(n.collider + (Vector2(0, beamWidth/2).rotated(rotation)))
		if n.dmgCooldown >= 15:
			#print("damaging!")
			
						
			n.dmgCooldown = 0
			n.target.takeDamage(self, n.target.dmgZones[n.dmgZone])
#			n.target.checkAggro(shooter)
			cleanTargetArray()
	
	#if not isPiercing:
	#	setBeamImpactParticle(position + $BeamLinePos/Real.points[1].rotated(rotation))

func cleanTargetArray():
	var toDelete = []
	
	var index = -1
	for n in damaging:
		index += 1
		if n.target.destroyed:
			toDelete.append(index)
			
	for i in range(toDelete.size()-1, -1, -1):
		damaging.erase(toDelete[i])

func getAttackAngle(impactedEntity):
	return rotation-PI
	
func getPointOfImpact(impactedEntity):
	for n in damaging:
		if n.targetid == impactedEntity.id:
			#print("hitting ", n.area.owner.display, " at collider ", n.collider)
			return n.collider + (Vector2(0, beamWidth/2).rotated(rotation))
	print("no collider!")
	return Vector2.ZERO

func get_class():
	return "Proj_Beam"
	
func canExplodeOnContact():
	return true
	
func explode():
	return

func postImpacting():
	return
