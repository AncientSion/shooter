extends Base_Unit
class_name Ground_Entity


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func doInit():
	.doInit()
	
func _physics_process(delta):
	pass
	
func getPossibleWeapons(index):
	return false
	
func getSpawnX(viewFrom, viewTo):
	return Globals.rng.randi_range(0 + 200, Globals.WIDTH - 200)
	
func getSpawnY(viewFrom, viewTo):
	return Globals.ROADY - texDim.y/2# - 300

func applyForce(force):
	pass
		
func handle_kill_explos():
	var amount = ceil((texDim.x + texDim.y) / 24)
#	print("killing ", self.display, ", explos: ", amount)
#	amount = 3
	var maxDelay:float
		
	for n in ceil(amount*1):
#		print("adding explo ", n)
#	for n in 1:
		var delay = rand_range(1.0, 4.2)
		maxDelay = max(maxDelay, delay)
		var scale = get_dmg_gfx_scale()
#		
		add_exp_fire_smoke_fx(scale, delay)
#		if rand_range(0, 1) > 0.5:
#			$EffectNodes.get_child($EffectNodes.get_child_count()-1).queue_free()
		
