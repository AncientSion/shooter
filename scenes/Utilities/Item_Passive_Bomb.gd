extends Item_BombRack
class_name Item_Passive_Bomb

func _physics_process(delta):
	doUse()
	
func doUse():
	if inCooldown(): return
	cooldown = baseCooldown
	isBeingUsed = true
	$AnimationPlayer.play("anim")
