extends Item_OrbitalArtillery_Active
class_name Item_OrbitalArtiller_Passiveww

func _physics_process(delta):
	doUse()
	
func doUse():
	if inCooldown(): return
	cooldown = baseCooldown
	isBeingUsed = true
	$AnimationPlayer.play("anim")
