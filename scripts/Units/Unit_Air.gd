extends Base_Unit
class_name Air_Unit

var descentTarget:int
var descentMod:int
var descentSpeed:int
	
func crashIsTriggered(remDmg):
	if $SM.state != $SM.states.crash:
		return (health < float(maxHealth)/2 and rand_range(0, 1) < remDmg / float(health))
	return false

func setupCrashing():
	false
