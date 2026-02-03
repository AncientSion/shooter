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
		
	$Sight.set_collision_mask_bit(4, 0)
	pass
	
func construct(init_orbit_radius, init_orbit_speed, init_orbit_radius_offset):
	orbit_radius = init_orbit_radius
	orbit_speed = init_orbit_speed
	orbit_radius_offset = init_orbit_radius_offset
	
func doInit():
	.doInit()
	maxSmoke = 0
#func doInit():
#	$Sprites/Main.scale = Vector2(0, 0)
#	var tween = get_tree().create_tween()#.set_parallel(true)
#	tween.tween_property($Sprites/Main, "scale", Vector2(.28, .28), 0.5)
	
#func setStats():
#	pass

func getPossibleWeapons(index):
	
	var shield_omni = Globals.weapon_shield_omni.instance()
	var shieldStats = {"maxShield": 200, "shieldRegenTime": 1.0, "shieldBreakTime": 0.0, "shieldFastCharge": 1.0, "shieldRadius": 20}
	shield_omni.construct(5, "Shield", shieldStats)
	shield_omni.position = Vector2(0, 0)
	shield_omni.add_shield_bar()
#	shield_omni.connect("updateShield_UI_Nodes", mainUI, "_on_updateShield_UI_Nodes")
#	shield_omni.connect("updateShieldBreakCooldown", mainUI, "_on_updateShieldBeakCooldown")
	
	return shield_omni
	
func _physics_process(_delta):
	time += _delta
	
#	var orbit_radius:int
#	var orbit_speed:float
#	var orbit_radius_offset:float

	position = Vector2(
		sin(time * orbit_speed + orbit_radius_offset) * orbit_radius,
		cos(time * orbit_speed + orbit_radius_offset) * orbit_radius
	)
	
	if orbitTarget != null:
		position += orbitTarget.global_position
	
#	rotation_degrees -= 1
#	rotation_degrees = round(rotation_degrees)
#	print(rotation_degrees)

func init_debug_menu_entry():
	return
	
func setOrbitTarget(target):
	orbitTarget = target
