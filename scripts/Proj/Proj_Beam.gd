extends Proj_Base
class_name Proj_Beam

#var	dmgType:int
#var velocity = Vector2.ZERO
#var minDmg:int
#var maxDmg:int
#var faction:int
var beamLength:int
var beamWidth:int
#var lifetime:float
#var projNumber:int
var origin:Weapon_Base
#var shooter

var texDim
#var active = true
var sweeptime:float = 0.0
var fusePartScale:float = 0.0
var fuseColor:Color
var fuseInterval:float = 0.05
var isStatic = false
var isPiercing = false
var cutIn:int = 5
var hits = 0
var maxHits = 3
var collide = Vector2.ZERO
#var impactForce = Vector2.ZERO
var dmgCooldown = 15
var counter:int = 0
var fadeMulti:float = 0.6

var deviation:float

var damaging = []
	
func constructProj(weapon):
	.constructProj(weapon)
	beamLength = weapon.beamLength
	beamWidth = weapon.beamWidth
	shooter = weapon.shooter
	origin = weapon
	
	fusePartScale = 5 + sqrt((minDmg+maxDmg)/4.0)
	fuseColor =  weapon.colors[1].lightened(0.1)
	
	setBeamColors(weapon)
	
func _ready():
	texDim = Vector2.ZERO
#
#	if faction == 0:
#		setFriendly()
#	elif faction == 1:
#		setHostile()
#	elif faction == 2:
#		setNeutral()
	$RayNodes/A.cast_to = Vector2(beamLength, 0)
	$RayNodes/B.cast_to = Vector2(beamLength, 0)
	setBeamWidth()
	beamFadeInOne()
	
func setFriendly():
#	faction = 0
#	$ColNodes/DmgNormal.set_collision_layer_bit(2, true)
#	$ColNodes/DmgNormal.set_collision_mask_bit(1, true)
	.setFriendly()
	$RayNodes/A.set_collision_mask_bit(1, true)
	$RayNodes/B.set_collision_mask_bit(1, true)
	
func setHostile():
#	faction = 1
#	$ColNodes/DmgNormal.set_collision_layer_bit(3, true)
#	$ColNodes/DmgNormal.set_collision_mask_bit(0, true)
	.setHostile()
	$RayNodes/A.set_collision_mask_bit(0, true)
	$RayNodes/B.set_collision_mask_bit(0, true)
	
func setNeutral():
#	faction = 2
#	$ColNodes/DmgNormal.set_collision_layer_bit(0, true)
#	$ColNodes/DmgNormal.set_collision_layer_bit(1, true)
	$ColNodes/DmgNormal.set_collision_mask_bit(2, true)
	$ColNodes/DmgNormal.set_collision_mask_bit(3, true)
	
func setBeamWidth():
	$BeamLinePos/Real.width = floor(beamWidth)
	$ColNodes/DmgNormal/ColShape.shape.extents.y = floor(beamWidth/2)
	
	$RayNodes/A.position.y = -beamWidth/2
	$RayNodes/B.position.y = beamWidth/2
	
func setBeamColors(weapon):
#	print(weapon.colors)
	$BeamLinePos/Real.texture.gradient.colors[1] = weapon.colors[1]
	$BeamLinePos/Real.texture.gradient.colors[2] = weapon.colors[1].lightened(0.6)
	$BeamLinePos/Real.texture.gradient.colors[3] = weapon.colors[1]

func _physics_process(_delta):
#	if lifetime > 0:
##		print(lifetime)
#		lifetime -= _delta
#		if lifetime <= 0:
##			print("endend")
#			on_lifetime_timeout()
	
#	print("lifetime remaining: ", lifetime)
	#print("____physics_process beam")
	if not isStatic:
		if is_instance_valid(origin):
			global_position = origin.get_node("Muzzle").global_position
			rotation_degrees = origin.global_rotation_degrees + deviation
#	elif isStatic:
##		global_position += Vector2(Globals.rng.randi_range(-1, 1), 0)
##		$BeamLinePos.scale.y += rand_range(-0.03, 0.03)
#
#		counter += 1
#		if counter == 5:
#			counter = 0
#			var explo = Globals.getExplo("basic", 8)
#			Globals.curScene.get_node("Various").add_child(explo)
#			explo.global_position.x = global_position.x
#			explo.global_position.y = $BeamLinePos/Real.points[1].x
#			explo.global_position += Vector2(Globals.rng.randi_range(-3, 3), Globals.rng.randi_range(-3, 3))
#			explo.rotation = -rotation
	
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
		
	$ColNodes/DmgNormal/ColShape.shape.extents.x = floor(beamEnd.x/2 + cutIn)
	$ColNodes/DmgNormal/ColShape.position.x = floor(beamEnd.x/2 + cutIn)
	$BeamLinePos/Real.points[1] = beamEnd + Vector2(0, 0)
	process_beam_damage()
	
	fuseInterval -= _delta
	if damaging.size():
#		print("damaging legit")
		if fuseInterval <= 0.0:
#			print("fuseInterval legit")
			fuseInterval = 0.05
	#		setBeamImpactParticle(n.collider + (Vector2(0, beamWidth/2).rotated(rotation)))
			setBeamImpactParticle(global_position + $BeamLinePos/Real.points[1].rotated(rotation))
		
#	queue_free()

func beamFadeInOne():
	$ColNodes/DmgNormal/ColShape.disabled = true
	var width = $BeamLinePos/Real.width
	$BeamLinePos/Real.width = 0
	var durA = .3 * fadeMulti
	lifetime += durA
	
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property($BeamLinePos, "modulate:a", 1.0, durA)
	tween.tween_property($BeamLinePos/Real, "width", width*0.5, durA)
	tween.set_parallel(false)
	tween.tween_callback(self, "beamFadeInTwo")

func beamFadeInTwo():
	$ColNodes/DmgNormal/ColShape.disabled = false
	var durB = .2 * fadeMulti
	lifetime += durB
	
	var tween = get_tree().create_tween()
	tween.tween_property($BeamLinePos/Real, "width", $BeamLinePos/Real.width*1.5, durB)
	tween.tween_callback(self, "beamFadeInThree")

func beamFadeInThree():
	var durC = .1 * fadeMulti
	lifetime += durC
	
	var tween = get_tree().create_tween()
	tween.tween_property($BeamLinePos/Real, "width", $BeamLinePos/Real.width*1.25, durC)
	tween.tween_callback(self, "initStaticBeam")

func initStaticBeam():
	if not isStatic: 
		return
	print("initStaticBeam")
	var dir = -1
	if global_position.x - Globals.PLAYER.global_position.x > 0:
		dir = 1
	var moveX = 200 + Globals.rng.randi_range(-40, 40)
	
	$Tween.interpolate_property(self, "position:x",
		global_position.x, global_position.x + moveX * dir, sweeptime,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func doBeamFadeOut():
	var dur = .3 * fadeMulti
#	print("fadeout over ", dur, " seconds")
	$ColNodes/DmgNormal.monitoring = false
	$ColNodes/DmgNormal.monitorable = false
	
	
	var tween = get_tree().create_tween()
	tween.tween_property($BeamLinePos, "modulate:a", 0.0, dur)
	tween.tween_property($BeamLinePos, "scale:y", 0.0, dur)
#	tween.tween_callback(self, "queue_free")
#
#
#	$Tween.interpolate_property($BeamLinePos, "modulate:a",
#		1.0, 0.0, dur,
#		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#	$Tween.interpolate_property($BeamLinePos, "scale:y",
#		1.0, 0.0, dur,
#		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#	$Tween.start()
#	yield($Tween, "tween_all_completed")
#	queue_free() 
	
func on_lifetime_timeout():
	doBeamFadeOut()

func _on_DmgNormal_area_entered(area):
	print("_on_Beam_area_ENTRY ", area.owner.display, ", area: ", area.name)
	
	for n in damaging:
		if n.targetid == area.owner.id:
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
		dict.target = area.owner
		dict.targetid = dict.target.id
		dict.display = dict.target.display
		damaging.append(dict)
		print("adding target ", dict.display, " #", dict.targetid)
	else:
#		print("piercing")
		for ray in $RayNodes.get_children():
			for n in damaging:
				ray.add_exception(n.area)
			ray.force_raycast_update()
			if ray.is_colliding():
				dict.target = area.owner
				dict.targetid = dict.target.id
				dict.display = dict.target.display
				var new = true
				for n in damaging:
					if n.targetid == dict.targetid:
						new = false
						break
				if new:
					damaging.append(dict)
					print("adding target ", dict.display, " #", dict.targetid)
				
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
#	print("frame ", Engine.get_idle_frames(), " adding fuse")
	var fuse = Globals.get("BEAM_IMPACT").instance()
	Globals.curScene.get_node("Various").add_child(fuse)
	fuse.emitting = true
	fuse.position = pos + Vector2(cutIn, 0).rotated(rotation)
	fuse.rotation = rotation
	fuse.process_material.emission_box_extents.y = floor(beamWidth * 0.8)
	fuse.process_material.scale = fusePartScale
	fuse.amount = 20
#	fuse.lifetime = 2.0
	fuse.process_material.color_ramp.gradient.colors[0] = fuseColor
	return fuse

func process_beam_damage():
	if not damaging.size(): return

#	print("process_beam_damage frame: ", Engine.get_idle_frames())
	for n in damaging:
		#print("process_beam_damage on: ", n.target.display, " cooldown at ", n.dmgCooldown)
		
		
		
		n.dmgCooldown += 1
		
		if n.dmgCooldown % 2 == 0:
			for ray in $RayNodes.get_children():
				ray.force_raycast_update()
#				print("raycast")
				if ray.is_colliding():
#					print("is_colliding")
					var collider = ray.get_collider()
#					print("collidiing with: ", collider.owner.display)
					if collider.owner.id == n.targetid:
						n.collider = ray.get_collision_point()
						break
#			setBeamImpactParticle(n.collider + (Vector2(0, beamWidth/2).rotated(rotation)))
		if n.dmgCooldown >= 15:
			#print("damaging!")
			
						
			n.dmgCooldown = 0
			n.target.takeDamage(self, Globals.getRawDamage(self.minDmg, self.maxDmg, n.target.dmgZones[n.dmgZone]))
#			n.target.checkAggro(shooter)
			cleanTargetArray()

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
	pass

func postImpacting():
	pass
	
func enterBoundary():
	pass
