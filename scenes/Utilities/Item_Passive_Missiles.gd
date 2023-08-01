extends Item_MissilePod
class_name Item_Passive_Missiles

func _physics_process(delta):
	doUse()

func doUse():
	if inCooldown(): return
	cooldown = baseCooldown
	isBeingUsed = true
	$AnimationPlayer.play("anim")
