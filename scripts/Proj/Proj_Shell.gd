extends Proj_Base
class_name Proj_Shell

var proc
var procAmount:int
#var type = 3

func _ready():
	pass
	
func constructProj(weapon):
	.constructProj(weapon)
	proc = weapon.proc
	procAmount = weapon.procAmount

func getAttackObject(target = null):
#	print(typeof(proc.type))
#	print(typeof(proc.lifetime))
#	print(typeof(impactForce))
	match proc.type:
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

func getBullet():
	var bullet = Globals.BULLET.instance()
#	match faction:
#		0:
#			bullet = Globals.BULLET_BLUE.instance()
#		1:
#			bullet = Globals.BULLET_RED.instance()

	bullet.constructProj(proc)
	return bullet

func getMissile(target = null):
	return 
	
func getBeam():
	return
	
func getShell():
	return
	
func getRail():
	var rail = Globals.RAIL.instance()
	rail.construct(faction, proc.dmgType, proc.speed, proc.minDmg, proc.maxDmg, proc.impactForce, proc.projSize)
	return rail
	
func on_lifetime_timeout():
	#var amount = ceil((texDim.y + texDim.x) / 10)
	var amount = 1
	
	if canExplodeOnContact():
		explode()
		
#	for n in amount:
#		var explo = Globals.getExplo("basic", (minDmg+maxDmg)/2)
#		explo.position = position
#		Globals.curScene.get_node("Various").add_child(explo)
		
	var degrees = 360
	var rot_rng = Globals.rng.randi_range(0, 359)
	var bullets = procAmount
	var angle = degrees/procAmount
	
	for number in procAmount:
		var proj = getAttackObject()
		proj.rotation_degrees = angle * (number+1) + rot_rng
		proj.position = position + Vector2(round(aoe)-5, 0).rotated(proj.rotation)
		Globals.PROJCONT.add_child(proj)
	queue_free()

func get_class():
	return "Proj_Shell"
