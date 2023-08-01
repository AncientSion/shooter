extends Weapon_Base
class_name Weapon_Proj

#proj
#type, display, turnrate, health, texture, projsize, projnumber, burst, rof, minDmg, maxDmg, deviation, speed
func construct(init_type:int, init_display:String, init_texture, init_projSize:float, init_projNumber:int, init_burst:int, init_rof:float, init_dmg, init_lifetime:float, init_deviation:int, init_speed:int):
	return
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
	lifetime = init_lifetime
	dmgType = init_dmg.dmgType
	deviation = init_deviation
	speed = init_speed
	
	cooldown = init_rof
