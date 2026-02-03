extends Weapon_Base
class_name Weapon_Missile

var steerForce:int
var displaceTimer:float
var displaceForce:float
	
func getMissile(target = null):
	var missile = Globals.MISSILE.instance()
	missile.constructProj(self)
	if target and missile.steerForce:
		missile.setHomingTarget(target)
		if vLaunch:
			missile.homing = false
			missile.homeTimer = 1.0
#			missile.rotation = PI*-0.5 
			missile.speed /= 4
	return missile
	
func getTorp(target = null):
	var torp = Globals.TORP.instance()
	torp.constructProj(self)
	if target and torp.steerForce:
		torp.setHomingTarget(target)
		if vLaunch:
			torp.homing = false
			torp.homeTimer = 1.5
			torp.rotation = PI*-0.5 
			torp.speed /= 3
	return torp
	
func fillStatsRows():
	subPanel_Stats.addEntry("Cooldown", rof)
	subPanel_Stats.addEntry("Projs / Burst", str(burst, " x ", projNumber))
	subPanel_Stats.addEntry("Velocity", speed)
	subPanel_Stats.addEntry("Damage", str(minDmg, " - ", maxDmg))
	subPanel_Stats.addEntry("Area of Effect", str(aoe))
	subPanel_Stats.addEntry("Deviation", deviation)
	return subPanel_Stats

func applyRecoilFromWeaponFire():
	return false
	
func is_in_range(pos):
	return true
	
func drawRange():
	draw_arc(Vector2.ZERO, speed*3, 0, TAU, 24, Color(1, 0, 0, 1), 1)
	
	if fof == 60:
		draw_arc(Vector2.ZERO, 600, deg2rad(-fof), deg2rad(fof), 24, Color(1, 1, 0, 1), 1)
	
func doMuzzleEffect():
	pass
	
func setProjPosition(all, current, proj):
	var launch = Vector2.ZERO
	if all == 1: 
		launch = Vector2(10, 0).rotated(global_rotation)
	elif vLaunch:
#		var xBorder = 5
		var width = 50# - xBorder*2
#		var x = xBorder + (width / (amount+1) * count)
		var x = 0 + (width / (all+1) * (current+1))
		launch = Vector2(0, -width/2 + x).rotated(global_rotation)
		
	proj.global_position = $Muzzle.global_position + launch

func getLaunchOffset(all, current):
	if not vLaunch:
		return Vector2.ZERO
	if all == 1: 
		return Vector2(0, 0).rotated(rotation)
	var emitterTotalWidth = 30 
	
	var this = emitterTotalWidth*2 / (all+1) * current
#	print(this)
	var launch = Vector2(0, emitterTotalWidth/2 - this).rotated(rotation)
	return launch
	
func get_class():
	return "Weapon_Missile"
