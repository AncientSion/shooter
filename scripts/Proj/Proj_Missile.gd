extends Proj_Base
class_name Proj_Missile

var steerForce
var target = null
var homing = false
	
func constructNew(weapon):
	faction = weapon.faction
	dmgType = weapon.dmgType
	speed = weapon.speed
	minDmg = weapon.minDmg
	maxDmg = weapon.maxDmg
	aoe = weapon.aoe
	lifetime = weapon.lifetime
	steerForce = weapon.steerForce
	projNumber =  weapon.projNumber
#	shooter = weapon.shooter
	
	type = 2
	scale = Vector2(weapon.projSize, weapon.projSize)
	

func setHomingTarget(homingTarget):
	target = homingTarget

func _ready():
	if target != null:
		homing = true

func _physics_process(delta):
	var seek = seek()#.limit_length(speed/2)
	accel += seek
	velocity += accel * delta
	velocity = velocity.limit_length(speed)
	#print(velocity.length())
	rotation = velocity.angle()
	position += velocity * delta
	
	if Globals.isOutOfBounds(position):
		explode()
		
#	print($Timer.time_left)
		
func seek(): 
	var steer = Vector2.ZERO
	
	if homing:
		if  not is_instance_valid(target) or target == null or target.destroyed:
			#print("target invalid, null or destroyed")
			return steer
		var desired = (target.position - position).normalized() * speed
		steer = (desired - velocity).normalized() * steerForce
		return steer
	else: return Vector2(1, 0).rotated(rotation) * speed

func get_class():
	return "Proj_Missile"
