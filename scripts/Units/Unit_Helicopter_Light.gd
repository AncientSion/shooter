extends Air_Unit
class_name Helicopter_Light

var display = "Helicopter_Light"

func _physics_process(_delta):
	pass
	
func process_movement(_delta):
	
	set_interest()
	set_danger()
	choose_direction()
	accel = chosen_dir.rotated(rotation) * maxSpeed
	accel = accel.limit_length(maxSpeed)
	velocity += accel * _delta
	velocity = velocity.limit_length(maxSpeed)

func doTurnaround():
#	$Sprites/Main.flip_h = !$Sprites/Main.flip_h
	mirrorTurrets()
	mirrorThrusters()
	mirrorVarious()
	mirrorColNodes()
	mirrorSprite()

func mirrorSprite():
	if $Sprites/Main.flip_h == true:
		for n in $Sprites.get_children():
			n.rotation = -(2*rotation)
			n.flip_h = false
			n.position.x *= -1
	else: 
		for n in $Sprites.get_children():
			n.rotation = 0
			n.flip_h = true
			n.position.x *= -1

func setUnitFacing():
	if $SM.state == $SM.states.crash:
		return
		
	if curTarget == null:
		if moveTarget.x - position.x < 0:
			if $Sprites/Main.flip_h == false:
				doTurnaround()
		else:
			if $Sprites/Main.flip_h == true:
				doTurnaround()
	else: doFaceTarget()

func getPossibleWeapons(index):
#	return
#	var weapon = Globals.getWeaponBase("Beamlance");
	var weapon = Globals.getWeaponBase("Heavy Machinecannon");
#	var weapon = Globals.getWeaponBase("Light Railgun");
#	var weapon = Globals.getWeaponBase("AI_Laser");
	
#	var weapon = Globals.getWeaponBase("Minelayer");
	return weapon
	
func setupCrashing():
	.setupCrashing()
	$Tween.interpolate_property(self, "maxSpeed", maxSpeed, getCrashSpeed(), 2.0)
	$Tween.start()
	$Tween.connect("tween_all_completed", self, "doInitCrash")

func getCrashSpeed():
	return max(30, maxSpeed / 4)
	
func getCrashAngle():
	return round(rand_range(9, 14))

func killByCrash():
	.killByCrash()
		
	for n in max_smoke * 2:
		var explo = Globals.getExplo("radial", get_dmg_gfx_scale())
		explo.position += position + get_point_inside_tex()
		explo.rotation = Globals.rng.randi_range(0, 2*PI)
		Globals.curScene.get_node("Various").add_child(explo)
	
func initAvoidValues():
	avoidValues = {"Player": 2.0, "Fighter": 2.0, "Helicopter_Light": 2.0, "Boundary": 5.0, "Obstacle": 5.0, "Cargohauler": 3.5, "City": 3.5}
