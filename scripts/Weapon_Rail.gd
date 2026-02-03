extends Weapon_Base
class_name Weapon_Rail

var curDeviation:float

func _ready():
#	print("ready rail: ", display)
	$Aim/AimA.points[0] = Vector2.ZERO
	$Aim/AimB.points[0] = Vector2.ZERO
	
#	$Aim/AimA.hide()
#	$Aim/AimB.hide()	
#	$Aim/LineA.hide()
#	$Aim/LineB.hide()
	$Aim/Angle.hide()

func weapon_process(_delta):
#	print("rail weapon_process")
	if isInActiveBurst():
		handleBursting(_delta)
	else:
		cooldown = max(cooldown - _delta, -rof)
	
	curDeviation = deviation + ((deviation * 6) * (cooldown + rof) / rof)
#	print(global_rotation_degrees)
	drawAimVector()
	set_all_cooldown_timers()
#	print(Engine.get_idle_frames(), "_weapon: ", global_rotation_degrees)
	
func drawAimVector():
	drawCurrentDeviationLINES()
#	drawCurrentDeviationARC()

func drawCurrentDeviationLINES():
#	print(Engine.get_idle_frames(), "_drawDevi: ", deg2rad(curDeviation))
	$Aim/AimA.points[1] = Vector2(800, 0).rotated(deg2rad(curDeviation))
	$Aim/AimB.points[1] = Vector2(800, 0).rotated(deg2rad(-curDeviation))
	
func drawCurrentDeviationARC():
#	print("draw aim frame: ", Engine.get_idle_frames())
	$Aim/Angle.polygon[1] = Vector2(800, 0).rotated(deg2rad(curDeviation))
	$Aim/Angle.polygon[2] = Vector2(800, 0).rotated(deg2rad(-curDeviation))

#func setPostFireCooldown():
#	cooldown = min(rof, cooldown + 0.5)

func hasViableFireSolution():
	var angleToTarget = rad2deg(curTarget.global_position.angle_to_point(global_position))
#	var dif = angleToTarget - global_rotation_degrees
#	print("dif: ", abs(round(dif)))
	if abs(round(angleToTarget - global_rotation_degrees)) == 360 or abs(angleToTarget - global_rotation_degrees) < fof:
		return curDeviation < deviation * 2
	return false
	
func getShotDeviation(projNumber, i):
	if linearDevi:
		return - curDeviation + ((curDeviation*2) / (projNumber+-1) * i)
	else:
		return rand_range(-curDeviation, curDeviation)

func get_class():
	return "Weapon_Rail"	
	
