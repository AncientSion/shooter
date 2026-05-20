extends Weapon_Shield_Base
class_name Weapon_Shield_Omni

var spriteScale:float

func _ready():
	pass
	
func do_sub_init_weapon():
	add_to_group("isShield")
	connect_shield_timer_signals()
	$ColNodes/Shield/A.shape.radius = shieldRadius
	spriteScale = shieldRadius / float(100) * 2
	$Shield.scale = get_shield_max_scale()
	
func _physics_process(_delta):
	pass
	
func is_in_range(pos):
	return false
	
func get_shield_max_scale():
	return Vector2(spriteScale, spriteScale)

func get_class():
	return "Weapon_Shield_Omni"
