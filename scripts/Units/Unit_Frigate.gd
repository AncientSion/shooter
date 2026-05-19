extends Capital
class_name Frigate

var display = "Frigate"

func _ready():
	pass
	
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
	
	rotation_degrees += 20.0 * _delta

func do_turnaround():
	return
	
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
#	return false
	match index:
		0:
#			return false
#			var shield = Globals.weapon_shield_dir.instance()
#			var stats = {"maxShield": 60, "shieldRegenTime": 0.5, "shieldBreakTime": 6.0, "shieldFastCharge": 0.75, "shieldDist": 80, "shieldLength": 50}
#			return shield.construct(5, "Shield", stats)
#			return shield
#			return Globals.getWeaponBase("Light Autocannon");
			var w = Globals.getWeaponBase("Heavy Autocannon");
			w.rof = 2.0
			return w
		1:
#			return false
#			return Globals.getWeaponBase("Heavy Autocannon");
			var w = Globals.getWeaponBase("Heavy Autocannon");
			w.rof = 2.0
			return w
		2:
#			return Globals.getWeaponBase("Heavy Autocannon");
			var w = Globals.getWeaponBase("Heavy Autocannon");
			w.rof = 2.0
			return w
	
			
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
	
func crash_step_one():
	.crash_step_one()
	$Tween.interpolate_property(self, "maxSpeed", maxSpeed, get_crash_velo(), 3.0)
	$Tween.start()
	$Tween.connect("tween_all_completed", self, "crash_step_two")
	
func set_hold_position():
	moveTarget = global_position
	$Tween.interpolate_property(self, "maxSpeed", maxSpeed, maxSpeed/4, 3.0)
	$Tween.start()
