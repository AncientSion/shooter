extends Item_OrbitalStrikeArty
class_name Item_Passive_OrbiArty

func _physics_process(delta):
	doUse()
	
func doUse():
	if inCooldown(): return
	cooldown = baseCooldown
	isBeingUsed = true
	$AnimationPlayer.play("anim")
