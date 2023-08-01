extends Proj_Base
class_name Proj_Bomb

var rota = 0.5
	
func construct(init_speed, init_minDmg, init_maxDmg, init_aoe, init_projSize, init_faction, init_projNumber = 1):
	return
	speed = init_speed
	minDmg = init_minDmg
	maxDmg = init_maxDmg
	aoe = init_aoe
	projSize = init_projSize
	faction = init_faction
	projNumber = init_projNumber
	
	scale = Vector2(init_projSize, init_projSize)
	dmgType = 0

func constructNew(weapon):
	faction = weapon.faction
	dmgType = weapon.dmgType
	speed = weapon.speed
	minDmg = weapon.minDmg
	maxDmg = weapon.maxDmg
	aoe = weapon.aoe
	lifetime = weapon.lifetime
	projNumber =  weapon.projNumber
	
	type = 2
	scale = Vector2(weapon.projSize, weapon.projSize)
	
func _ready():
	pass
	
func _physics_process(_delta):
	if rotation_degrees > 90 :
		rotation_degrees -= rota
		rotation_degrees = max(90, rotation_degrees)
	elif rotation_degrees < -90:
		rotation_degrees -= rota
		if rotation_degrees <= -180:
			rotation_degrees = 180
	else:
		rotation_degrees += rota
		rotation_degrees = min(90, rotation_degrees)
	
	accel = Vector2(1, 0).rotated(rotation) * speed
	velocity += accel * _delta
	velocity += gravity_vec
	position += velocity * _delta
	
	if Globals.isOutOfBounds(position):
		explode()
	
func _on_Timer_timeout():
	explode()

func get_class():
	return "Proj_Bomb"
