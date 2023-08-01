extends Proj_Base
class_name Proj_Rail

func init():
	pass
	
func constructNew(weapon):
	faction = weapon.faction
	dmgType = weapon.dmgType
	speed = weapon.speed
	minDmg = weapon.minDmg
	maxDmg = weapon.maxDmg
	aoe = weapon.aoe
	lifetime = weapon.lifetime
	projSize = weapon.projSize
	projNumber = weapon.projNumber
	shooter = weapon.shooter
	
	type = 6
	scale = Vector2(weapon.projSize, weapon.projSize)
	
func _ready():
#	lifetime = 0
	velocity = Vector2(1, 0).rotated(rotation) * speed

func _physics_process(_delta):
	velocity *= 0.998
	velocity += gravity_vec * _delta / 2
	rotation = velocity.angle()
	position += velocity * _delta
	if Globals.isOutOfBounds(position):
		queue_free()
	#print(velocity.length())

func on_lifetime_timeout():
	return

func get_class():
	return "Proj_Rail"
