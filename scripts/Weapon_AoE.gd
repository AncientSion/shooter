extends Weapon_Shell
class_name Weapon_AoE

func _ready():
	pass

func doFire(_target):
	#	print("doFire")
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
		
	cooldown = rof
	
	if curTarget == null:
		return
		
	for n in projNumber:
		var proj = getAttackObject(curTarget)
		proj.get_node("Sprites").hide()
		Globals.curScene.get_node("Projectiles").add_child(proj)
		var devi = Vector2(Globals.rng.randi_range(-deviation, deviation), Globals.rng.randi_range(-deviation, deviation))
		var tPos = curTarget.global_position + devi
		
		proj.global_position = tPos
		proj.speed = 0
#		proj.set_physics_process(false)
		
		var marker = Globals.AOE_MARK.instance()
		marker.construct(lifetime, aoe*2, aoe)
#		marker.construct(proj.lifetime, 100)
		proj.add_child(marker)
