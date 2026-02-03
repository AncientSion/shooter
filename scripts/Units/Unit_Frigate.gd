extends Capital
class_name Frigate

var display = "Frigate"

func _ready():
	pass
	
func doInit():
	.doInit()
	for n in $Mounts.get_children():
		n.add_health_bar()
		n.scaleBar("healthbar", 0.5)
	
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
	
	toggleThrusterparticles()

func toggleThrusterparticles():
	if accel.x > 10:
		if direction.x == 1:
			$ThrusterNodes/Aft.get_node("Particle2D").emitting = true
			$ThrusterNodes/Front.get_node("Particle2D").emitting = false
		else:
			$ThrusterNodes/Front.get_node("Particle2D").emitting = true
			$ThrusterNodes/Aft.get_node("Particle2D").emitting = false
	elif accel.x < -10:
		if direction.x == 1:
			$ThrusterNodes/Front.get_node("Particle2D").emitting = true
			$ThrusterNodes/Aft.get_node("Particle2D").emitting = false
		else:
			$ThrusterNodes/Aft.get_node("Particle2D").emitting = true
			$ThrusterNodes/Front.get_node("Particle2D").emitting = false
	else:
		$ThrusterNodes/Front.get_node("Particle2D").emitting = false
		$ThrusterNodes/Aft.get_node("Particle2D").emitting = false
		
	if accel.y > 10:
		$ThrusterNodes/UpA.get_node("Particle2D").emitting = true
		$ThrusterNodes/UpB.get_node("Particle2D").emitting = true
		$ThrusterNodes/DownA.get_node("Particle2D").emitting = false
		$ThrusterNodes/DownB.get_node("Particle2D").emitting = false
	elif accel.y < -10:
		$ThrusterNodes/DownA.get_node("Particle2D").emitting = true
		$ThrusterNodes/DownB.get_node("Particle2D").emitting = true
		$ThrusterNodes/UpA.get_node("Particle2D").emitting = false
		$ThrusterNodes/UpB.get_node("Particle2D").emitting = false
	else:
		$ThrusterNodes/DownA.get_node("Particle2D").emitting = false
		$ThrusterNodes/DownB.get_node("Particle2D").emitting = false
		$ThrusterNodes/UpA.get_node("Particle2D").emitting = false
		$ThrusterNodes/UpB.get_node("Particle2D").emitting = false
	
#func getPossibleWeapons(index):
#	var shield = Globals.weapon_shield_dir.instance()
#	var stats = {"maxShield": 60, "shieldRegenTime": 0.5, "shieldBreakTime": 6.0, "shieldFastCharge": 0.75, "shieldDist": 80, "shieldLength": 50}
#	shield.construct(5, "Shield", stats)
#	return shield
	
	
func getPossibleWeapons(index):
#	return 
	match index:
		0:
#			var shield = Globals.weapon_shield_dir.instance()
#			var stats = {"maxShield": 60, "shieldRegenTime": 0.5, "shieldBreakTime": 6.0, "shieldFastCharge": 0.75, "shieldDist": 80, "shieldLength": 50}
#			return shield.construct(5, "Shield", stats)
#			return shield
			return Globals.getWeaponBase("Light Autocannon");
		1:
			return Globals.getWeaponBase("Light Autocannon");
			
			
func addStartingItems():
	return
#	addItem(Globals.getItemBase("Minelayer (Passive)"))
	var item = Globals.getItemBase("Conv. Bomb Rack (A)")
	item.result[0].minDmg *= 0.4
	item.result[0].maxDmg *= 0.4
	item.result[0].stacks = 5
	item.result[0].speed = 40
#	item.scaleDmg(0.3)
	addItem(item)
	
func initAvoidValues():
	avoidValues = {"Player": 1.0, "Fighter": 0.0, "Helicopter_Light": 0.0, "Boundary": 5.0, "Obstacle": 5.0, "Cargohauler": 1.5, "City": 1.5, "Boss": 2.0}
	
func setupCrashing():
	.setupCrashing()
	$Tween.interpolate_property(self, "maxSpeed", maxSpeed, getCrashSpeed(), 3.0)
	$Tween.start()
	$Tween.connect("tween_all_completed", self, "doInitCrash")
