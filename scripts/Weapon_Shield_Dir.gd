extends Weapon_Shield_Base
class_name Weapon_Shield_Dir

func _ready():
	pass
	
func _subready():
#	add_shield_bar()
#	scaleBar("shieldbar", 0.7)
	$Shield.position.x = shieldDist
	$Shield.scale.y = $Shield.scale.y / 36 * shieldLength
	$ColNodes/Shield/A.position.x = shieldDist
	$ColNodes/Shield/A.shape.extents.y = (36 / 0.4 * $Shield.scale.y)
	$Sprites/Main.hide()
	add_to_group("isShield")
	
func _physics_process(_delta):
	pass

func isInActiveBurst():
	return false
	
func canFire():
	return false
	
func is_in_range(pos):
	return global_position.distance_to(pos) < 800
	
func wpn_has_valid_target():
	if curTarget == null or not is_instance_valid(curTarget) or curTarget.destroyed == true or curTarget.ready == false:
		return false
	if isInArc(global_position.direction_to(curTarget.global_position)): 
		return true
	return false
	
#func handleHullDamage(remDmg, pos, angle):
#	return
	
func get_shield_end_scale():
	return Vector2(0.4, 0.4 / 36 * shieldLength)
	
func get_class():
	return "Weapon_Shield_Dir"
	

