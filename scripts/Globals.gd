extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
const BLACK = preload("res://styles/blackBorder.tres")
const RED = preload("res://styles/redBorder.tres")
const YELLOW = preload("res://styles/yellowBorder.tres")

const AOE_MARK = preload("res://scenes/AoE_Marker.tscn")

const EXPLO_00_01 = preload("res://scenes/Explosion_00_01.tscn")
const EXPLO_01_01 = preload("res://scenes/Explosion_01_01.tscn")
const EXPLO_PART = preload("res://scenes/PartExplo.tscn")
const EXPLO_PART_S = preload("res://scenes/PartExploShield.tscn")
const EXPLO_PART_W = preload("res://scenes/PartExploWreckage.tscn")
const BEAM_IMPACT = preload("res://scenes/BeamImpact.tscn")

const BULLET_BLUE = preload("res://scenes/Proj/Proj_Bullet_Blue.tscn")
const BULLET_RED = preload("res://scenes/Proj/Proj_Bullet_Red.tscn")

const MISSILE = preload("res://scenes/Proj/Proj_Missile.tscn")
const BOMB = preload("res://scenes/Proj/Proj_Bomb.tscn")
const SHELL = preload("res://scenes/Proj/Proj_Shell.tscn")
const BEAM = preload("res://scenes/Proj/Proj_Beam.tscn")
const RAIL = preload("res://scenes/Proj/Proj_Rail.tscn")

const ROCK = preload("res://scenes/Units/Obstacle.tscn")

const DMG_LABEL: PackedScene = preload("res://scenes/DamageLabel.tscn")
const RTLABEL: PackedScene = preload("res://scenes/Mission_UI.tscn")
const SMOKE: PackedScene = preload("res://scenes/Parti_Smoke.tscn")
const SMOKE_GROUND: PackedScene = preload("res://scenes/Parti_Smoke_Ground.tscn")
const SMOKE_WIDE: PackedScene = preload("res://scenes/Parti_Smoke_Wide.tscn")
const FIRE: PackedScene = preload("res://scenes/Parti_Fire.tscn")
const HEALTHBAR: PackedScene = preload("res://scenes/Health_Bar.tscn")
const SHIELDBAR: PackedScene = preload("res://scenes/Shield_Bar.tscn")
const HEALTHLABEL: PackedScene = preload("res://scenes/Health_Label.tscn")

const DUMMY: PackedScene = preload("res://scenes/Units/Dummy.tscn")

const REWARD_BOX: PackedScene =  preload("res://scenes/Utilities/Reward_Crate.tscn")
const REWARD: PackedScene =  preload("res://scenes/Utilities/Reward.tscn")

const PLAYERSCENE = preload("res://scenes/Player.tscn")

const ITEM_BASE = preload("res://scenes/Utilities/Item_Base.tscn")
const ITEM_PASSIVE = preload("res://scenes/Utilities/Item_Passive.tscn")

const WEAPONENTRYCONT = preload("res://ui//WeaponEntryCont.tscn")
const ITEMENTRYCONT = preload("res://ui//ItemEntryCont.tscn")

var PLAYER
var INTERMISSION = load("res://scenes/Intermission.tscn")
var STAGEZERO = load("res://scenes/Stage_0.tscn")

var handler_spawner
var handler_mission

var curLevel:int
var curScene = null

var ENEMYAI =  load("res://scenes/EnemyList.tscn")

var WIDTH:int
var HEIGHT:int
var ROADY:int
var MUDY:int
var ZOOM:Vector2 = Vector2(1.0, 1.0)
var SCREEN = Vector2.ZERO
var MOUSE = Vector2.ZERO
var BASEGRAVITY = Vector2.ZERO
var DIFFICULTY:int
var UI = null
var ENVI = null
var PAUSE = null

var frameCounter:int = 0

var mod = 1
var rng
var wpn
var isPaused = false
var idcounter = 0
var weapon_proj
var weapon_shell
var weapon_aoe
var weapon_missile
var weapon_rail
var weapon_beam
var weapon_shield
var mountain
var clouds = []

var weaponSprites = []
var buildingSprites = []

var bullet_wpn_sprites = []
var laser_wpn_sprites = []
var missile_wpn_sprites = []

var item_sprites = []

var projSprites = []

var itemTemplates = []
var weaponTemplates = []
var itemResources = []

var JSONitems = []

var slowed = false

func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()
	#randomize()
	loadAssets()
	loadSprites("weapons/png/", weaponSprites)
	loadSprites("items/", item_sprites)
	loadProjSprites()
	loadItemTemplatesJSON()
	loadItemResources()
	loadWeaponTemplates()
	SCREEN = get_viewport().size
	PLAYER = PLAYERSCENE.instance()
	instancetHandlers()
	
func instancetHandlers():
	print("instancetHandlers")
	handler_spawner = load("res://scripts/Handler_Spawner.gd").new()
	add_child(handler_spawner)
	handler_spawner.set_physics_process(false)
	handler_mission = load("res://scripts/Handler_Mission.gd").new()
	add_child(handler_mission)
	handler_mission.set_physics_process(false)
	
func _physics_process(delta):
	if Input.is_action_just_pressed("reflex"):
		Globals.slowed = !Globals.slowed
		if Globals.slowed:
#			Engine.set_time_scale(0.25)
			Engine.set_time_scale(2)
		else:
			Engine.set_time_scale(1)
	frameCounter += 1
#
#	 var image = Image.new()
#    image.load(ProjectSettings.globalize_path(filepath))
#    return image
	
	
func loadSprites(path, target):
#	print("loadWeaponSprites")
#	var path = )
	var dir = Directory.new()
	dir.open(str("res://textures/", path))
	dir.list_dir_begin()
	while true:
		var file_name = dir.get_next()
#		print("filename: ", file_name)
		if file_name == "":
			#break the while loop when get_next() returns ""
			break
		elif !file_name.begins_with(".") and file_name.ends_with(".import"):
#			print("loading")
			#get_next() returns a string so this can be used to load the images into an array.
#			var image = Image.new()
#			image.load(ProjectSettings.globalize_path(path + file_name))
#			image = load(ProjectSettings.globalize_path(path + file_name)
			target.append(load(str("res://textures/", path) + file_name.replace(".import", "")))
	dir.list_dir_end()
	
#	print("sprites: ", target.size())
	
func loadProjSprites():
	projSprites.append(load(str("res://textures/Bomb_01.png")))
	
#func loadSprites(path, target):
#	var path = "res://textures/", path)
#	var dir = Directory.new()
#	dir.open(path)
#	dir.list_dir_begin()
#	while true:
#		var file_name = dir.get_next()
#		if file_name == "":
#			#break the while loop when get_next() returns ""
#			break
#		elif !file_name.begins_with(".") and !file_name.ends_with(".import"):
#			#get_next() returns a string so this can be used to load the images into an array.
#			item_sprites.append(load(path + file_name))
#	dir.list_dir_end()
		
func loadAssets():
	print("loadAssets")
	loadWeapons()
	loadMountains()
	loadClouds()
	loadBuildings()
	
func loadWeapons():
	weapon_proj = preload("res://scenes/Weapon_Proj.tscn")
	weapon_missile = preload("res://scenes/Weapon_Missile.tscn")
	weapon_shell = preload("res://scenes/Weapon_Shell.tscn")
	weapon_aoe = preload("res://scenes/Weapon_AoE.tscn")
	weapon_beam = preload("res://scenes/Weapon_Beam.tscn")
	weapon_shield = preload("res://scenes/Weapon_Shield.tscn")
	
func loadMountains():
	mountain = preload("res://scenes/Mountain_L_1.tscn")

func loadClouds():
	var amount = 4
	
	for n in amount:
		var scene = load(str("res://scenes/Cloud_" + str(n+1) + ".tscn"))
		clouds.append(scene)
		
func loadBuildings():
	var amount = 4
	for n in amount:
		var name = "building_0" + str(n+1)
		var sprite = load(str("res://textures/background/" + name + ".png"))
		buildingSprites.append(sprite)
		
func getId():
	idcounter += 1
	return idcounter
	
func getRandomEntry(array):
	if not len(array): return null
	return array[randi() % array.size()]
	
func getRandomEntryAndRemove(array):
	if not len(array): return null
	var pick = randi() % array.size()
	var ret = array[pick]
	array.remove(pick)
	return ret
	
func getExplo(type, damage):
	var explo
	match type:
		"basic": 
			explo = EXPLO_PART.instance()
		"wreck":
			explo = EXPLO_PART_W.instance()
		"shield":
			explo = EXPLO_PART_S.instance()
			
	explo.construct()
	var baseDmg = 6.0
	var scale:float  = sqrt(damage/baseDmg)
	explo.scale = Vector2(scale, scale)
	return explo

func getPointInDir(dist, angle, origin):
	var x = round(origin.x + dist * cos(angle* PI / 180));
	var y = round(origin.y + dist * sin(angle* PI / 180));
	return Vector2(x, y)

func getSpecificBaseWeaponByName(display):
	for n in weaponTemplates:
		#print("getSpecificBaseWeaponByName")
		#print(n.display)
		if n.display == display:
			return constructWeapon(n.duplicate(true))
			
func getRandomBaseWeaponByType(type):
	var options = []
	for n in weaponTemplates:
		if n.type == type and n.forPlayer == 1:
			options.append(n)
			
	var pick = options[Globals.rng.randi_range(0, len(options)-1)]
	
	return constructWeapon(pick.duplicate(true))
	
func constructWeapon(data):
#	print("constructWeapon")
	var weapon;
	var dmg = {"dmgType": data.dmgType, "min": data.minDmg, "max": data.maxDmg, "aoe": data.aoe}
	match data.type:
		1:
			weapon = Globals.weapon_proj.instance()
#			weapon.construct(data.type, data.display, data.texture, data.projSize, data.projNumber, data.burst, data.rof, dmg, data.lifetime, data.deviation, data.speed)
			weapon.constructNew(data)
		2:
			weapon = Globals.weapon_missile.instance()
			weapon.constructNew(data)
#			weapon.construct(data.type, data.display, data.texture, data.projSize, data.projNumber, data.burst, data.rof, dmg, data.deviation, data.speed, data.steerForce)
		4:
			weapon = Globals.weapon_beam.instance()
			weapon.constructNew(data)
#			weapon.construct(data.type, data.display, data.texture, data.speed, data.beamWidth, data.lifetime, data.projNumber, data.burst, data.rof, dmg, data.deviation)
		6:
			weapon = Globals.weapon_proj.instance()
			weapon.constructNew(data)
#			weapon.construct(data.type, data.display, data.texture, data.projSize, data.projNumber, data.burst, data.rof, dmg, data.lifetime, data.deviation, data.speed)
		
	weapon.desc = data.desc
#	print(weapon.get_node("Sprite").scale)
	return weapon

func loadWeaponTemplates():
	print("loadWeaponTemps")
#	var array = ["key", "value"]
#	var dicti = {}
#	dicti[array[0]] = array[1]
#	print(dicti)
	var file = File.new()
	var header = []
	var line = -1
	
#	print("before open")
	file.open("res://csv/weapontemplates.csv", file.READ)
#	print("openn")
	while !file.eof_reached():
#		print("while")
		var csv = file.get_csv_line()
		line += 1
		if line == 0:
			for n in csv:
				header.append(str(n))
		elif csv.size() < 2:
			break
		elif line > 0:
			var dict = {}
			dict[header[0]] = int(csv[0])
			dict[header[1]] = str(csv[1])
			dict[header[2]] = int(csv[2])
			dict[header[3]] = float(csv[3])
			dict[header[4]] = int(csv[4])
			dict[header[5]] = str(csv[5])
			dict[header[6]] = str(csv[6])
			dict[header[7]] = float(csv[7])
			dict[header[8]] = int(csv[8])
			dict[header[9]] = int(csv[9])
			dict[header[10]] = int(csv[10])
			dict[header[11]] = float(csv[11])
			dict[header[12]] = int(csv[12])
			dict[header[13]] = int(csv[13])
			dict[header[14]] = int(csv[14])
			dict[header[15]] = int(csv[15])
			dict[header[16]] = float(csv[16])
			dict[header[17]] = int(csv[17])
			dict[header[18]] = int(csv[18])
			dict[header[19]] = int(csv[19])
			dict[header[20]] = int(csv[20])
			weaponTemplates.append(dict)

func getItemByName(display):
	for n in itemTemplates:
		#print("getSpecificBaseWeaponByName")
		#print(n.display)
		if n.display == display:
			return constructItem(n)
			
func constructItem(pick):
	print("constructItem ", pick.display)
	var base = Globals.get(pick.constructor).instance()
	if pick.script != "":
		var string = str("res://scenes/Utilities/Item_", pick.script, ".gd")
		base.set_script(load(string))
	base.constructNew(pick)
	return base

func getPossibleLoot_Items():
	return itemTemplates
		
func loadItemTemplatesJSON():
	var file_path = "res://json/missile.json"
	var file = File.new()
	file.open(file_path, File.READ)
	var content_as_text = file.get_as_text()
	var json = parse_json(content_as_text)
	
	for item in json:
		item.type = int(item.type)
	for n in json:
		itemTemplates.append(n)

func loadItemResources():
	return
	var dirPath = "res://ressources/items/"
	var dir = Directory.new()
	dir.open(dirPath)
	dir.list_dir_begin()
	var file_name = dir.get_next()

	while(file_name!=""): 
		if dir.current_is_dir():
			pass
		else:
			itemResources.append(dirPath+"/"+file_name)
		file_name = dir.get_next()


func getPossibleWeaponMods(type):
	print("getPossibleWeaponMods")
	var table = []
	var file = File.new()
	var line = -1
	var dict = {"id": 0}
	var legal = false
	file.open("res://csv/weaponmods.csv", file.READ)
	
	# 9 proj 10 missile 11 shell 12 beam 13 shield
	
	while !file.eof_reached():
		var csv = file.get_csv_line()
		line += 1
		if line > 0:
			if csv.size() < 3:
#				print("__appending to loottable")
				table.append(dict.duplicate())
				break
			#print("_____reading line ", line)
			
			if int(csv[0]) > 0:
				legal = int(csv[8+type]) == 1
				if legal and dict.id != int(csv[0]):
					if dict.id > 0:
#						print("__appending to loottable")
						table.append(dict.duplicate())
						
#					print("init new dict on line ", line, ", id #", int(csv[0]))
					dict = {}
					dict.id = int(csv[0])
					dict.type = int(csv[1])
					dict.name = str(csv[2])
					dict.weight = int(csv[3])
					dict.cost = int(csv[4])
					dict.hits = int(csv[5])
					dict.mods = []
					
			elif legal:
#				print("__adding mod: ", str(csv[6]))
				dict.mods.append({"prop": str(csv[6]), "effect": float(csv[7]), "type": str(csv[8])})
	file.close()
	return table

func doAdvanceLevel():
	PLAYER.exitLevel()
#	PAUSE = curScene.get_node("Pause")
#	curScene.remove_child(PAUSE)
	curScene.remove_child(UI)
	
	var index = -1
	for n in UI.get_node("Place/Topright/AI_PC/VBoxC").get_children():
		index += 1
		#print(n.display)
		if index > 0: n.queue_free()
	
	for n in UI.get_node("LootNodes").get_children():
		n.queue_free()
		
	for root in curScene.get_node("Neutral_Units").get_children():
		for n in root.get_children():
			if n.name == "Item":
				n.doUnloadBits()
			if n.name == "Item" or n.name == "Weapon":
				if not n.UI_node == null:
					n.UI_node.queue_free()
				if not n.statsPanel == null:
					n.statsPanel.queue_free()
		root.queue_free()

	for n in UI.get_node("Place/TopleftLower/WeaponStatsPos").get_children():
		n.get_node("Tween").stop_all()
		n.set("modulate", Color(1, 1, 1, 1))
		n.hide()
	for n in UI.get_node("Place/BottomleftHigher/ItemStatsPos").get_children():
		n.get_node("Tween").stop_all()
		n.set("modulate", Color(1, 1, 1, 1))
		n.hide()
	
	curScene.get_node("Player_Pos").remove_child(PLAYER)
	curScene.queue_free()
	
	match curLevel:
		0:
			curLevel = 1
			curScene = STAGEZERO.instance()
		1:
			curLevel = 0
			curScene = INTERMISSION.instance()

	curScene.add_child(UI)
	get_tree().get_root().add_child(curScene)
	get_tree().set_current_scene(curScene)

func isOutOfBounds(position):
	if position.x < 0 or position.x > Globals.WIDTH:
		#print("is out of bounds LEFT RIGHT!")
		return true
#		print(self.display, " out of bounds X", global_position)
#		self.lootValue = 0
#		kill()
	if position.y < 0 or position.y > Globals.ROADY + 10:
		#print("is out of bounds UP DOWN!")
		return true
#		print(self.display, " out of bounds Y", global_position)
#		self.lootValue = 0
#		kill()
	return false
	
func getSmokeNode(scale = 1):
	var smoke = SMOKE.instance()
	smoke.scale = Vector2(scale, scale)
	return smoke
	
func getFireNode(scale = 1):
	var fire = FIRE.instance()
	fire.scale = Vector2(scale, scale)
	return fire

func getTex(search, texType):
	var string = str("res://.import/", search)
#	print("looking for ", string)
	var data
	match texType:
		0: 
			data = item_sprites
		1: 
			data = weaponSprites
			
#	print("sprites: ", weaponSprites.size())
		
	for n in data:
#		print(n.load_path)
		if n.load_path.left(len(string)) == string:
			return n
	
#	print("cant get weapon tex")
	return data[len(data)-1]
	
func togglePause():
	isPaused = !isPaused
	get_tree().paused = !get_tree().paused
	curScene.get_node("UI/Pause").visible = !curScene.get_node("UI/Pause").visible
	curScene.get_node("UI/PauseSep").visible = !curScene.get_node("UI/PauseSep").visible
	
	if not isPaused:
		for item in PLAYER.get_node("Items").get_children():
			if item.type == 0:
				item.subPanel_Stats.set("modulate", Color(1, 1, 1, 1))
				item.subPanel_Stats.hide()
		for wpn in PLAYER.get_node("Weapons").get_children():
				wpn.subPanel_Stats.set("modulate", Color(1, 1, 1, 1))
				wpn.subPanel_Stats.hide()
	else:
		for item in PLAYER.get_node("Items").get_children():
			if item.type == 0:
				item.subPanel_Stats.get_node("Timer").stop()
				item.subPanel_Stats.get_node("Tween").stop_all()
				item.subPanel_Stats.set("modulate", Color(1, 1, 1, 1))
		for wpn in PLAYER.get_node("Weapons").get_children():
				wpn.subPanel_Stats.get_node("Timer").stop()
				wpn.subPanel_Stats.get_node("Tween").stop_all()
				wpn.subPanel_Stats.set("modulate", Color(1, 1, 1, 1))

func addBigTextAndFade(text):
	var font = DynamicFont.new()
	font.font_data = load("res://various/Roboto-Medium.ttf")
	font.size = 32
	var node = Globals.DMG_LABEL.instance()
	node.get_node("CenterContainer/Label").set("custom_fonts/font", font)
	#node.get_node("CenterContainer/Label").set("custom_fonts/size", 50)
	node.get_node("CenterContainer/Label").text = text
	Globals.curScene.get_node("UI/Center").add_child(node)
	
	node.modulate.a = 0
	var tween = node.get_node("Tween")
	
	tween.interpolate_property(node, "modulate:a",
			0, 1, 1,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	
	tween.interpolate_property(node, "scale",
			Vector2(1, 1), Vector2(4, 4), 2,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(node, "modulate:a",
			1, 0, 2,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)#
	tween.start()
	yield(tween, "tween_all_completed")
	node.queue_free()
