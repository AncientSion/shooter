extends Weapon_Shield_Base
class_name Weapon_Shield_Omni

var spriteScale:float

func _ready():
	pass
	
func _subready():
	$ColNodes/Shield/A.shape.radius = shieldRadius
	spriteScale = shieldRadius / float(100) * 2
	$Shield.scale = Vector2(spriteScale, spriteScale)
	
func _physics_process(_delta):
	pass
	
func is_in_range(pos):
	return false
	
func weaponHasValidTarget():
	return false
	
func get_shield_end_scale():
	return Vector2(spriteScale, spriteScale)

func get_class():
	return "Weapon_Shield_Omni"
