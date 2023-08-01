extends Base_Unit
class_name Blob

var display = "Blob"
var time = 0.0
var orbit_radius:int
var orbit_speed:float
var orbit_radius_offset:float
var orbitTarget:Base_Entity

func _ready():
	print("adding")
	indestructable = true
	if faction == 0:
		setFriendly()
	elif faction == 1:
		setHostile()
	elif faction == 2:
		setNeutral()
	pass
	
func construct(init_orbit_radius, init_orbit_speed, init_orbit_radius_offset):
	orbit_radius = init_orbit_radius
	orbit_speed = init_orbit_speed
	orbit_radius_offset = init_orbit_radius_offset
	
func doInit():
	pass
	
func setStats():
	pass
	
func _physics_process(_delta):
	time += _delta
	position = Vector2(
		sin(time * orbit_speed + orbit_radius_offset) * orbit_radius,
		cos(time * orbit_speed + orbit_radius_offset) * orbit_radius
	)
	
	if orbitTarget != null:
		position += orbitTarget.global_position
	
#	rotation_degrees -= 1
#	rotation_degrees = round(rotation_degrees)
#	print(rotation_degrees)

func initAIList():
	return

func takeDamage(entity, dmgMulti):
	var pos = entity.getPointOfImpact(self)
	var angle = entity.getAttackAngle(self)
	handleShieldDamage(10, pos, angle)
		
func handleShieldDamage(shieldDmgTaken, pos, angle):
	addShieldExplosion(shieldDmgTaken, pos, angle)
	var labelPos = pos + Vector2(0, -(texDim.y/2) -10)
	createFloatingLabel(0, labelPos, Vector2(0, -100), Color(0, 0, 1, 1))
	
func setOrbitTarget(target):
	orbitTarget = target
