extends Item_BombRack_Active
class_name Item_BombRack_Passive

func _physics_process(delta):
	doUse()
	
func doUse():
	if inCooldown(): return
	cooldown = baseCooldown
	isBeingUsed = true
	$AnimationPlayer.play("anim")
