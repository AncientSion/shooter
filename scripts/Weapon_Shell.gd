extends Weapon_Base
class_name Weapon_Shell

var proc#:Proj_Base
var procAmount:int

func getShell():
	#return self.proc.duplicate(true)
	var shell = Globals.SHELL.instance()
#	func construct(init_dmgType, init_speed, init_minDmg, init_maxDmg, init_aoe, init_lifetime, init_proc, init_procAmount, init_faction, init_projSize, init_projNumber = 1, init_shooter = false):
#	shell.construct(dmgType, speed, minDmg, maxDmg, aoe, lifetime, proc, procAmount, faction, projSize)
	shell.constructProj(self)
#	shell.rotation_degrees = global_rotation_degrees + rand_range(-deviation, deviation)
	shell.get_node("Sprites/Main").visible = false
	shell.disableTriggerCollisionNodes()
	return shell

func get_class():
	return "Weapon_Shell"

func drawAimVector():
	var targetUp = Vector2.ZERO
	var targetDown = Vector2.ZERO
	
	var close = 200
	targetUp = Vector2(close, 0).rotated(deg2rad(deviation))
	targetDown = Vector2(close, 0).rotated(deg2rad(-deviation))
	$Aim/AimA.points[0] = targetUp
	$Aim/AimA.points[1] = targetDown
	
	var mid = 450
	targetUp = Vector2(mid, 0).rotated(deg2rad(deviation))
	targetDown = Vector2(mid, 0).rotated(deg2rad(-deviation))
	$Aim/AimB.points[0] = targetUp
	$Aim/AimB.points[1] = targetDown
