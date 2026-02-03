extends SM
class_name Building_SM

func _ready():
	add_state("wander")
	add_state("crash")
	add_state("idle")
	add_state("close")
#	set_state(states.close)

func _state_logic(delta):
	match state:
		states.wander:
			pass
		states.crash:
			pass
		states.idle:
			pass
		states.close:
			pass

func do_init():
	set_state(states.idle)
