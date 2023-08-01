extends Item_Base
class_name Item_Passive
	
func _ready():
	pass
	
func _physics_process(delta):
	pass
	
func hasChargesLeft():
	return false
	
func isInActiveUse():
	return false

func consumeCharge():
	return false
	
func addCharge():
	return false

func _on_AnimationPlayer_animation_finished(anim_name):
	return false

func toggle():
	return false
	
func doUse():
	return false
