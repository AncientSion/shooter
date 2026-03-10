extends Item_Base
class_name Item_BombRack_Active

func _ready():
	var interval = 0.4
	var start = 0.2
	initCallMethodTrack("effector", interval, start)
	
func effector():
	
	for n in result:
		var devi = 0
		var proj = Globals.BOMB.instance()
		proj.constructProj(n)
		
		Globals.PROJCONT.add_child(proj)
		
		proj.rotation_degrees = global_rotation_degrees + 0 + Globals.rng.randi_range(-devi, devi)
		proj.global_position = global_position
		
func setQualityMods():
	return

	
func item_use_check_process(_delta):
	
	checkTimer -= _delta
	
	if checkTimer > 0.0:
		return
	checkTimer = 1.0
	
	if not canUse():
		return
	
	if owner.curTarget == null:
		return
	
	var d = owner.global_position.distance_to(owner.curTarget.global_position)
	var p = owner.curTarget.global_position.x - owner.global_position.x
	var a = rad2deg(owner.curTarget.global_position.angle_to_point(owner.global_position))
	
	var direction = (owner.curTarget.global_position - owner.global_position).normalized()
	var velo = owner.velocity.normalized()
	var dot = direction.dot(velo)
#w
#	print("dist: ", round(d))
#	print("angle: ", str("%.2f" % a))
#	print("dot: ", str("%.2f" % dot))
#
	if dot > 0.0:
#		print("angle: ", str("%.2f" % a))
		if a < 130 and a > 50:
			doUse()
			remCharges += 1
#				get_item("Conv. Bomb Rack (A)").doUse()



