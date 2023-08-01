extends Weapon_Base
class_name Weapon_Missile

var steerForce:int

#proj
#type, display, turnrate, health, texture, projsize, projnumber, burst, rof, minDmg, maxDmg, deviation, speed
func construct(init_type:int, init_display:String, init_texture, init_projSize:float, init_projNumber:int, init_burst:int, init_rof:float, init_dmg, init_deviation:int, init_speed:int, init_steerForce:int):
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
	dmgType = init_dmg.dmgType
	deviation = init_deviation
	speed = init_speed
	steerForce = init_steerForce
	
	cooldown = init_rof
	
func getMissile(target = null):
	var lifetime = 3.0
	var impact = Vector2.ZERO
	var missile = Globals.MISSILE.instance()
#	func construct(init_faction, init_dmgType, init_speed, init_minDmg, init_maxDmg, init_aoe, init_lifetime, init_impactForce, init_steerForce, init_projSize,  init_target, init_projNumber = 1, init_shooter = null):

#	missile.construct(faction, dmgType, speed, minDmg, maxDmg, aoe, lifetime, impact, steerForce, projSize, target, projNumber, shooter)
	missile.constructNew(self)
	return missile
	
func fillStatsRows(statsPanel):
	statsPanel.addEntry("Cooldown", rof)
	statsPanel.addEntry("Projs / Burst", str(burst, " x ", projNumber))
	statsPanel.addEntry("Velocity", speed)
	statsPanel.addEntry("Damage", str(minDmg, " - ", maxDmg))
	statsPanel.addEntry("Area of Effect", str(aoe))
	statsPanel.addEntry("Deviation", deviation)
	return statsPanel
