extends Proj_Base
class_name Proj_Bullet

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
	
	type = 1
	scale = Vector2(weapon.projSize, weapon.projSize)
	
	
func _ready():
	velocity = Vector2(1, 0).rotated(rotation)

func _physics_process(delta):
	position += velocity * speed * delta
#	position += transform.x * speed * delta
	if Globals.isOutOfBounds(position):
		queue_free()

func get_class():
	return "Proj_Bullet"
