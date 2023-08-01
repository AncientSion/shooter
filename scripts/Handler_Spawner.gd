extends Node2D

# Load enemy scenes on game startup
const truck_light = preload("res://scenes/Units/Unit_Truck_Light.tscn")
const truck_heavy = preload("res://scenes/Units/Unit_Truck_Heavy.tscn")
const jeep = preload("res://scenes/Units/Unit_Jeep.tscn")
const artillery = preload("res://scenes/Units/Unit_Arty.tscn")
const heli_light = preload("res://scenes/Units/Unit_Helicopter.tscn")
const heli_heavy = preload("res://scenes/Units/Unit_Helicopter_02.tscn")
const fighter = preload("res://scenes/Units/Unit_Fighter.tscn")
const frigate = preload("res://scenes/Units/Unit_Frigate.tscn")
const destroyer = preload("res://scenes/Units/Unit_Destroyer.tscn")
const cruiser = preload("res://scenes/Units/Unit_Cruiser.tscn")
const aa_tower = preload("res://scenes/Units/Unit_AA_Tower.tscn")
const mobile_aa_light = preload("res://scenes/Units/Unit_Mobile_AA_Light.tscn")
const mobile_aa_heavy = preload("res://scenes/Units/Unit_Mobile_AA_Heavy.tscn")
const city = preload("res://scenes/Units/Unit_City.tscn")
const cargohauler = preload("res://scenes/Units/Unit_Cargo_Hauler.tscn")
const boss = preload("res://scenes/Units/Unit_Boss.tscn")
const blob = preload("res://scenes/Units/Unit_Blob.tscn")
const drone = preload("res://scenes/Units/Unit_Drone.tscn")

var player
var wave = Array()
var enemies = Array()
var waveFullStrength = int()
var waveRemStrength = int()
var totalWeight = 0
var tickCounter = 0

var diffiUI
var waveUI
var diffiTimer

func _init():
	pass
	
func _physics_process(delta):
	return
	tickCounter += 1
	if tickCounter == 60:
		tickCounter = 0
		checkForReinforcing()
	
#func _ready():
	
func doInit():
	name = "Handler_Spawner"
	print("init ", name)
	player = Globals.PLAYER
	set_physics_process(true)
	
	diffiUI = Globals.curScene.get_node("UI/Place/TopleftRighter/Diffi/Vbox/HBox1/Label2")
	diffiUI = Globals.curScene.get_node("UI/Place/TopleftRighter/Diffi/Vbox/HBox2/Label2")
	diffiTimer = Globals.curScene.get_node("Timers/DifficultyTimer")
	
	diffiUI.text = str(Globals.DIFFICULTY)
	diffiTimer.connect("timeout", self, "_on_diffiTimer_timeout")
	diffiTimer.wait_time = 5.0
	diffiTimer.start()

	var forceStrength:int = Globals.DIFFICULTY
	wave = getUnitData()
	if 0:
		adjustWaveDataByMission()
		wave = pickEnemiesIntoWave(wave, forceStrength)
	spawnWave()
	
func getSpawnOutsideView(enemy):
	var cam = Globals.curScene.get_node("CamA")
	#var viewport = get_viewport_rect().size
	var camPos = cam.position
	var SCREEN = Globals.SCREEN
	var from = Vector2(camPos - (SCREEN/2))
	var to = Vector2(from + SCREEN)
	return enemy.getSelfSpawnPosition(from, to)
	
func getUnitData():
	return [
		#{"type": truck, "tresh": 1, "amount": 0, "strength": 1, "weight": 10},
		{"type": fighter, "display": "Fighter", "legal": true, "tresh": 1, "amount": 0, "strength": 3, "weight": 6},
		{"type": heli_light, "display": "Heli_L", "legal": true, "tresh": 14, "amount": 1, "strength": 5, "weight": 3},
		{"type": heli_heavy, "display": "Heli_H", "legal": true, "tresh": 22, "amount": 0, "strength": 4, "weight": 3},
		{"type": frigate, "display": "Frigate", "legal": true, "tresh": 35, "amount": 0, "strength": 3, "weight": 2},
		{"type": destroyer, "display": "Destroyer", "legal": true, "tresh": 55, "amount": 0, "strength": 7, "weight": 1},
		{"type": cruiser, "display": "Cruiser", "legal": true, "tresh": 55, "amount": 0, "strength": 7, "weight": 1},
		{"type": jeep, "display": "Jeep", "legal": true, "tresh": 1, "amount": 0, "strength": 2, "weight": 2},
		{"type": artillery, "display": "Artillery", "legal": true, "tresh": 25, "amount": 0, "strength": 5, "weight": 1},
		{"type": aa_tower, "display": "AA Tower", "legal": false, "tresh": 25, "amount": 0, "strength": 4, "weight": 2},
		{"type": mobile_aa_light, "display": "Mobile AA Light", "legal": true, "tresh": 25, "amount": 0, "strength": 4, "weight": 2},
		{"type": mobile_aa_heavy, "display": "Mobile AA Heavy", "legal": true, "tresh": 25, "amount": 0, "strength": 4, "weight": 2},
		{"type": drone, "display": "Drone", "legal": false, "tresh": 25, "amount": 0, "strength": 4, "weight": 2},
		{"type": boss, "display": "Boss", "legal": true, "tresh": 250, "amount": 0, "strength": 4, "weight": 2}]
	
func pickEnemiesIntoWave(roster, reinforcePoints):
	totalWeight = 0
	for entry in roster:
		if entry.tresh >= Globals.DIFFICULTY or entry.legal == false: continue
		totalWeight += entry.weight
		
	if totalWeight > 0:
		while reinforcePoints >= 0:
			var dice = Globals.rng.randi_range(0, totalWeight)
			var current = dice
	#		print("totalWeight: ", totalWeight)
	#		print("rolled ", dice)
			for entry in roster:
				if entry.tresh >= Globals.DIFFICULTY or entry.legal == false: continue
				if current > entry.weight:
					current -= entry.weight
				else:
					entry.amount += 1
					reinforcePoints -= entry.strength
					break
		for entry in roster:
			if entry.amount > 0:
				print("reinforcing by: ", entry.amount, "x ", entry.display)
	return roster
			
func adjustWaveDataByMission():
	if Globals.handler_mission.pick == Globals.handler_mission.missions.PROTECT_CITY or Globals.handler_mission.pick ==  Globals.handler_mission.missions.SALVAGE_CARGOHAULER:
		for entry in wave:
			if entry.display == "Jeep":
				entry.legal = false
				
func checkForReinforcing():
	#return
	waveUI.text = str(waveRemStrength, "/", waveFullStrength)
	if waveRemStrength > waveFullStrength / 2: return
	print("wave under half initial strength: ", waveRemStrength, "/", waveFullStrength)
		
	var reinforceStrength:int = floor(waveFullStrength/4)
	print("reinforcing by: ", reinforceStrength)
	Globals.addBigTextAndFade(str("Reinforce by ", reinforceStrength))
	
	wave = pickEnemiesIntoWave(wave, reinforceStrength)
	
	for element in wave:
		var amount = element["amount"]
		for i in amount:
			element["amount"] -= 1
			waveRemStrength += element.strength
			spawnSingleFromWave(element["type"].instance())
		
	print("post reinforce: ", waveRemStrength, "/", waveFullStrength)	
	addDifficulty(2)
	#Globals.curScene.initAIList()
	
func spawnWave():
	for element in wave:
		var amount = element["amount"]
		for i in amount:
			element["amount"] -= 1
			spawnSingleFromWave(element["type"].instance())
	
	waveFullStrength = Globals.DIFFICULTY
	waveRemStrength = Globals.DIFFICULTY

func doInstanceEnemy(name):
	return get(name).instance()

func spawnSingleFromWave(enemy):
#	enemy.queue_free()
#	return
	Globals.curScene.addUnit("Enemy_Units", enemy)
	var pos = getSpawnOutsideView(enemy)
	enemy.position = pos
#	print("deploying enemy: ", enemy.display, " at ", pos)
	enemy.position = Vector2(player.position.x, player.position.y - 200 + Globals.curScene.get_node("Enemy_Units").get_children().size() * 125)
#	enemy.rotation = PI/3
#	enemy.kill()
	enemy.setHostile()
	enemy.setArmament()
#	print(enemy.get_node("Mounts").get_child(0).get_child(0).get_node("Sprite").scale)
	enemy.setDirection()
	enemy.doInit()
#	enemy.speed = 0
#	enemy.activeBehavior = 2
	enemy.connect("isDestroyed", self, "_on_enemy_from_wave_destroyed", [enemy])
	#print("spawning ", enemy.display, ": ", enemy.position, ", rot: ", enemy.rotation_degrees)

func spawnSpecial(timer):
	timer.queue_free()
			
	var enemy = destroyer.instance()
	Globals.curScene.addUnit("Enemy_Units", enemy)
	var pos = getSpawnOutsideView(enemy)
	enemy.position = pos
#	enemy.kill()
	enemy.setHostile()
	enemy.setArmament()
	enemy.setDirection()
	enemy.doInit()
	enemy.visible = false
	enemy.setInactive()
	
	enemy.connect("isDestroyed", self, "_on_enemy_from_wave_destroyed", [enemy])
	
	Globals.curScene.doZoom(1, 1.5, 0.25)
	
	var timerB = Timer.new()
	Globals.curScene.add_child(timerB)
	timerB.connect("timeout", enemy, "doDelayedWarpIn", [timerB])
	timerB.wait_time = 1
	timerB.start()
	
	print("spawnSPECIAL ", enemy.display, ": ", enemy.position, ", rot: ", enemy.rotation_degrees)
	
func _on_enemy_from_wave_destroyed(enemy):
	#print("_on_enemy_from_wave_destroyed: ", enemy.display)
	for n in wave:
		if n.display == enemy.display:
			waveRemStrength -= n.strength
			
	print("wave strength: ", waveRemStrength, "/", waveFullStrength)

func _on_diffiTimer_timeout():
	#print("_on_SpawnTimer_timeout")
	addDifficulty(1)
#	diffiTimer.stop()
#	return
	diffiTimer.start()
	
func addDifficulty(value):
	Globals.DIFFICULTY += value
	waveFullStrength += value
	diffiUI.text = str(Globals.DIFFICULTY)
	#print("difficulty now ", Globals.DIFFICULTY)
	Globals.addBigTextAndFade("Diff up")
	
