extends SM
class_name DroneShield_SM

func _ready():
	add_state("wander")
	add_state("idle")
	add_state("crash")

func _state_logic(delta):
	match state:
		states.idle:
			pass
		states.wander:
			pass

func do_init():
	set_state(states.idle)
