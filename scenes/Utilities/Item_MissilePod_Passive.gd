extends Item_MissilePod_Active
class_name Item_MissilePod_Passive

func _physics_process(delta):
	doUse()

func doUse():
	if inCooldown(): return
	cooldown = baseCooldown
	isBeingUsed = true
	$AnimationPlayer.play("anim")
