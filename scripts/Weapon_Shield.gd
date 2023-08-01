extends Weapon_Base
class_name Weapon_Shield

export var shieldLength:int = 36
export var shieldDist:int = 60

func _ready():
	addShieldBar()
	var scale = 0.4 / 36 * shieldLength
	$Shield.position.x = shieldDist
	$Shield.scale.y = scale
	$ColNodes/Shield/A.position.x = shieldDist
	$ColNodes/Shield/A.shape.extents.y = (36 / 0.4 * $Shield.scale.y)
	add_to_group("isShield")
	
func _physics_process(delta):
	pass
	
func handleControlNodes():
		for n in $ControlNodes.get_children():
			n.rect_position = get_parent().global_position + n.offset

func construct(init_type, init_display, init_shield, init_shieldDist = 60, init_shieldLength = 36):
	type = init_type
	display = init_display
	shield = init_shield
	shieldDist = init_shieldDist
	shieldLength = init_shieldLength
	
	maxShield = init_shield

func isInActiveBurst():
	return false
	
func canFire():
	return false
	
func isInRange(pos):
	return global_position.distance_to(pos) < 600
	
func weaponHasValidTarget():
	if curTarget == null or not is_instance_valid(curTarget) or curTarget.destroyed == true or curTarget.ready == false: return false
	if isInArc(global_position.direction_to(curTarget.global_position)): 
		return true
	return false
	
func handleHullDamage(remDmg, pos, angle):
	return
		
func unpowerShield():
#	shieldbar.queue_fwwwwwwwwwwree()
#	shieldbar = null
	print("shield is visible: ", visible)
	if not active: return
	shieldbar.hide()
	active = false
	$ColNodes/Shield.monitorable = false
	$ColNodes/Shield.monitoring = false
	for n in $ColNodes/Shield.get_children():
		n.disabled = true
	
	$Tween.interpolate_property($Shield, "modulate:a",
			1.0, 0.0, 0.6,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	
	$Tween.interpolate_property($Shield, "scale",
			Vector2(1, 1), Vector2(3.5, 3.5), 0.6,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	
#	yield($Tween, "tween_all_completed")
#
#	$Tween.interpolate_property($Shield, "modulate:a",
#			1.0, 0.0, 0.5,
#			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#	$Tween.start()
#
#	$Tween.interpolate_property($Shield, "scale",
#			Vector2(1, 1), Vector2(2, 2), 0.5,
#			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#	$Tween.start()
