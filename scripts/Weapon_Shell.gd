extends Weapon_Base
class_name Weapon_Shell

var proc:Proj_Base
var procAmount:int

#type, display, turnrate, health, texture, projsize, projnumber, burst, rof, deviation, speed, procType, procAmount
func construct(init_type:int, init_display:String, init_texture, init_projSize:float, init_projNumber:int, init_burst:int, init_rof:float, init_dmg, init_deviation:int, init_speed:int, init_proc, init_procAmount:int, init_lifetime:float):
	type = init_type
	display = init_display
	texture = init_texture
	projSize = init_projSize
	projNumber = init_projNumber
	burst = init_burst
	rof = init_rof
	minDmg = init_dmg.min
	maxDmg = init_dmg.max
	aoe = init_dmg.aoe
	dmgType = init_dmg.dmgType
	deviation = init_deviation
	speed = init_speed
	proc = init_proc
	procAmount = init_procAmount
	lifetime = init_lifetime
	
	cooldown = init_rof
	
func getShell():
	#return self.proc.duplicate(true)
	var shell = Globals.SHELL.instance()
#	func construct(init_dmgType, init_speed, init_minDmg, init_maxDmg, init_aoe, init_lifetime, init_proc, init_procAmount, init_faction, init_projSize, init_projNumber = 1, init_shooter = false):
#	shell.construct(dmgType, speed, minDmg, maxDmg, aoe, lifetime, proc, procAmount, faction, projSize)
	shell.constructNew(self)
	shell.get_node("Sprite").visible = false
	shell.disableCollisionNodes()
	return shell
