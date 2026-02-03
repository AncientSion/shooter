extends Capital
class_name Cargo_Hauler

var display = "Cargohauler"
	
func process_movement(_delta):
#	if $SM.state == $SM.states.crash:
#		return
		
	set_interest()
	set_danger()
	choose_direction()
	accel = chosen_dir.rotated(rotation) * maxSpeed
	accel = accel.limit_length(maxSpeed)
	velocity += accel * _delta
	velocity = velocity.limit_length(maxSpeed)
	
func getPossibleWeapons(index):
	var shield = Globals.weapon_shield_dir.instance()
	var stats = {"maxShield": 60, "shieldRegenTime": 0.5, "shieldBreakTime": 6.0, "shieldFastCharge": 0.75, "shieldDist": 80, "shieldLength": 50}
	shield.construct(5, "Shield", stats)
	shield.add_shield_bar()
	shield.scaleBar("shieldbar", 0.5)
	return shield

func applyForce(force):
	return

func onWarpInDone():
	.onWarpInDone()
	$SM.set_state($SM.states.wander)

func set_new_target():
	pass
