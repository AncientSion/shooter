extends Mission_Base
class_name Mission_Survive_Time

func _ready():
	pass
	
func _physics_process(delta):
	pass
	
func set_base_props():
	code = "SURVIVE"
	title = "Survive Interception Attempt"
	difficulty = 0
	reward = 0
	desc = "Enemy forces are hunting you—defend your position until extraction.\n Stay alive at all costs."
	
func mission_final_setup_self():
	do_init(10)
	do_setup()
	Globals.PLAYER.connect("_has_warped_in", self, "do_start_mission")

func do_init(init_time):
	maxTime = init_time
	timeRemain = init_time
	
func do_setup():
	pass
