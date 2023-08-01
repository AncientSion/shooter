extends Capital
class_name Boss

var display = "Boss"

func _ready():
	pass
#	$ThrusterNodes/Aft/Particle2D.process_material.scale = 10
	
#	var amount = 1
#	for n in amount:
#		var blob = Globals.handler_spawner.doInstanceEnemy("blob")
#		blob.setHostile()
#		blob.construct(100, 1, TAU/amount*(n+1))
#		Globals.curScene.get_node("Enemy_Units").add_child(blob)
#		blob.position = global_position + Vector2(200, 0).rotated(Globals.rng.randi_range(0, 359))
#		blob.setOrbitTarget(self)


func doInit():
	
	yield(get_tree().create_timer(1), "timeout")
	
	var amount = 3
	for n in amount:
		var drone = Globals.handler_spawner.doInstanceEnemy("drone")
		Globals.curScene.get_node("Enemy_Units").add_child(drone)
		drone.setHostile()
		drone.setArmament()
		drone.global_position = global_position + Vector2(200, 0).rotated(Globals.rng.randi_range(0, 359))
		drone.setEscortTarget(self)
		drone.doInit()
#		blob.setOrbitTarget(self)


func setStats():
	pass
	
func doTurnaround():
	pass
	
func getPossibleWeapons(index):
	return false
#	if index < 1:
#		return Globals.getSpecificBaseWeaponByName("Light Missile")
	if index < 4:
		return Globals.getSpecificBaseWeaponByName("Heavy Autocannon")
	else:
		var weapon = Globals.weapon_shield.instance()
#		construct(init_type, init_display, init_health, init_turnrate, init_shield, init_shieldDist = 60, init_shieldLength = 36):
		weapon.construct(5, "Shield", 120, 70, 72)
		return weapon
	match index:
		0:
			var weapon = Globals.weapon_proj.instance()
			weapon.construct(1, "Heavy Autocannon", 1, 15, false, 1, 1, 2, 3, 6, 8, 3, 425)
			return weapon
		1:
			var weapon = Globals.weapon_proj.instance()
			weapon.construct(1, "Heavy Autocannon", 1, 15, false, 1, 1, 2, 3, 6, 8, 3, 425)
			return weapon
		2:
			var weapon = Globals.weapon_proj.instance()
			weapon.construct(1, "Heavy Autocannon", 1, 15, false, 1, 1, 2, 3, 6, 8, 3, 425)
			return weapon
		3:
			var weapon = Globals.weapon_proj.instance()
			weapon.construct(1, "Heavy Autocannon", 1, 15, false, 1, 1, 2, 3, 6, 8, 3, 425)
			return weapon
		4:
			var weapon = Globals.weapon_proj.instance()
			weapon.construct(1, "Heavy Autocannon", 1, 15, false, 1, 1, 2, 3, 6, 8, 3, 425)
			return weapon
		5:
			var weapon = Globals.weapon_proj.instance()
			weapon.construct(1, "Heavy Autocannon", 1, 15, false, 1, 1, 2, 3, 6, 8, 3, 425)
			return weapon

func getSelfSpawnPosition(viewFrom, viewTo):
	return Vector2(Globals.WIDTH/2, Globals.HEIGHT/2 -200)
