extends Item_Base
class_name Item_Minelayer_Active

func _ready():
	
	var interval:float = result[0].interval
	var start:float = 0.2
	initCallMethodTrack("effector", interval, start)
#	cooldown = 1.0
	
#func _physics_process(delta):
#	doUse()

#func doUse():
#	if inCooldown():
#		return
#	cooldown = baseCooldown
#	isBeingUsed = true
#	$AnimationPlayer.play("anim")

func effector():
	
	for n in result:
		var devi = 0
		var proj = Globals.MINE.instance()
		proj.constructProj(n)
		
		Globals.PROJCONT.add_child(proj)
		
		proj.global_position = global_position
		proj.get_node("Origin").global_position = global_position
		proj.originPoint = global_position
#		proj.rotation = global_rotation - PI + rand_range(-0.3, 0.3) * PI/2
		proj.nextWayPoint = global_position + Vector2(proj.speed * proj.timeRem, 0).rotated(global_rotation - PI + rand_range(-0.15, 0.15) * PI/2)
		proj.state = 1
		proj.get_node("Target").global_position = proj.nextWayPoint
#		proj.velocity = Vector2(1, 0).rotated(proj.rotation) * proj.speed / 4
#		proj.timeRem *= 2
		
func setQualityMods():
	return
