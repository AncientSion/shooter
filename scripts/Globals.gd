extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const WHITE:Color = Color(1, 1, 1, 1)
const RED:Color = Color(1, 0, 0, 1)
const GREEN:Color = Color(0, 1, 0, 1)
const BLUE:Color = Color(0, 0, 1, 1)
const GRAY:Color = Color(0.5, 0.5, 0.5, 1)

const LIGHTGREEN:Color = Color(0.73, 0.91, 0, 1.0)
const YELLOW:Color = Color(1.0, 0.63, 0.0, 1.0)
const ORANGE:Color = Color(0.91, 0.17, 0.0, 1.0)
const MAGENTA:Color = Color(0.7, 0, 1.0, 1.0)

#var LIME = Color(0.04, 0.88, 0.53, 1.0)
#var MAGENTA = Color(0.7, 0, 1.0, 1.0)
#var ORANGE = Color(0.91, 0.17, 0.0, 1.0)
#var YELLOW = Color(1.0, 0.63, 0.0, 1.0)
#var WHITE = Color(1.0, 1.0, 1.0, 1.0)
#var LIGHTGREEN = Color(0.73, 0.91, 0, 1.0)
#var GREEN = Color(0.17, 1.0, 0.0, 1.0)

const AIMDEBUG:bool = false
const SIGHTDEBUG:bool = false

const AOE_MARK = preload("res://scenes/AoE_Marker.tscn")

const EXPLO_00_01 = preload("res://scenes/Explosion_00_01.tscn")
const EXPLO_01_01 = preload("res://scenes/Explosion_01_01.tscn")
const EXPLO_PART = preload("res://scenes/PartExplo.tscn")
const EXPLO_PART_RADIAL = preload("res://scenes/PartExploRadial.tscn")
const EXPLO_PART_S = preload("res://scenes/PartExploShield.tscn")
const EXPLO_PART_W = preload("res://scenes/PartExploWreckage.tscn")
const BEAM_IMPACT = preload("res://scenes/BeamImpact.tscn")
const HULL_DMG =  preload("res://scenes/HullDmg.tscn")

const POI = preload("res://addon/POI.tscn")
const MARKER = preload("res://addon/Marker.tscn")

const BULLET = preload("res://scenes/Proj/Proj_Bullet.tscn")
#const BULLET_BLUE = preload("res://scenes/Proj/Proj_Bullet_Blue.tscn")
#const BULLET_RED = preload("res://scenes/Proj/Proj_Bullet_Red.tscn")

const shock_shader = preload("res://scenes/Shockwave_Shader.tscn")
const MISSILE = preload("res://scenes/Proj/Proj_Missile.tscn")
const TORP = preload("res://scenes/Proj/Proj_Torp.tscn")
const BOMB = preload("res://scenes/Proj/Proj_Bomb.tscn")
const MINE = preload("res://scenes/Proj/Proj_Mine.tscn")
const SHELL = preload("res://scenes/Proj/Proj_Shell.tscn")
const BEAM = preload("res://scenes/Proj/Proj_Beam.tscn")
const RAIL = preload("res://scenes/Proj/Proj_Rail.tscn")
const MACE = preload("res://scenes/Proj/Proj_Mace.tscn")

const ROCK = preload("res://scenes/Units/Obstacle.tscn")

const DMG_LABEL: PackedScene = preload("res://scenes/DamageLabel.tscn")
const TEXT_LABEL: PackedScene = preload("res://scenes/Text_Label.tscn")
#const RTLABEL: PackedScene = preload("res://scenes/Mission_UI.tscn")
const SMOKE: PackedScene = preload("res://scenes/Parti_Smoke.tscn")
const SMOKE_GROUND: PackedScene = preload("res://scenes/Parti_Smoke_Ground.tscn")
const SMOKE_WIDE: PackedScene = preload("res://scenes/Parti_Smoke_Wide.tscn")
#const FIRE: PackedScene = preload("res://scenes/Parti_Fire.tscn")
const FIRESMOKE: PackedScene = preload("res://scenes/Parti_FireSmoke.tscn")
const EMPTY_SHELL: PackedScene = preload("res://scenes/Part_Shell_Emitter.tscn")
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

var PLAYER:Node = null

var GAMESCREEN:Node = null
var MAP_SCENE:Node = null
var MAIN_MENU:Node = null

var INTERMISSION = load("res://scenes/Intermission.tscn")
var STAGEZERO = load("res://scenes/Stage_0.tscn")

var handler_spawner
var handler_mission
var handler_map

var curScene:Base_Level

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


var reso_options = [Vector2(2560, 1440), Vector2(1920, 1080), Vector2(1600, 900), Vector2(1366, 768)]
var zoom_options =  [1.33, 1.0, 0.66, 2.0]

#var frameCounter:int = 0

var mod = 1
var rng
var isPaused = false
var idcounter = 0
var weapon_proj:PackedScene
var weapon_shell:PackedScene
var weapon_aoe:PackedScene
var weapon_missile:PackedScene
var weapon_rail:PackedScene
var weapon_beam:PackedScene
var weapon_melee:PackedScene
var weapon_shield_dir:PackedScene
var weapon_shield_omni:PackedScene
var mountain
var clouds_large = []
var clouds_small = []
var clouds_all = []

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
	load_weapons_csv()
	SCREEN = get_viewport().size
	PLAYER = PLAYERSCENE.instance()
	instantiate_handlers()
	
func instantiate_handlers():
	print("instantiate_handlers")
	handler_spawner = load("res://scripts/Handler_Spawner.gd").new()
	handler_spawner.name = "Spawner"
	add_child(handler_spawner)
	handler_spawner.set_physics_process(false)
	
	handler_mission = load("res://scripts/Handler_Mission.gd").new()
	handler_mission.name = "Mission"
	add_child(handler_mission)
	handler_mission.set_physics_process(false)
	
#	handler_map = load("res://scenes/Map.tscn").instance()
#	handler_map.name = "Map"
#	add_child(handler_map)
	
func _physics_process(_delta):
	if Input.is_action_just_pressed("middle_click"):
		Globals.slowed = !Globals.slowed
		if Globals.slowed:
			Engine.set_time_scale(0.5)
		else:
			Engine.set_time_scale(1)
#	frameCounter += 1
	
	if Input.is_action_just_pressed("nullGravity"):
		if Globals.BASEGRAVITY != Vector2.ZERO:
			Globals.BASEGRAVITY = Vector2.ZERO
		else:
			Globals.BASEGRAVITY = Vector2(0, 300)
#
#	 var image = Image.new()
#    image.load(ProjectSettings.globalize_path(filepath))
#    return image

func set_resolution():
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_EXPAND, Globals.SCREEN)
	Globals.GAMESCREEN.get_node("Menu_BG").rect_min_size = Globals.SCREEN
	
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
	weapon_rail = preload("res://scenes/Weapon_Rail.tscn")
	weapon_melee = preload("res://scenes/Weapon_Melee.tscn")
	weapon_shield_dir = preload("res://scenes/Weapon_Shield_Dir.tscn")
	weapon_shield_omni = preload("res://scenes/Weapon_Shield_Omni.tscn")
	
func loadMountains():
	return

func loadClouds():
	for n in 7:
		var number:String = str(n+1)
		if len(number) < 2:
			number = str("0", number) 
		var sprite = load(str("res://textures/Cloud_L_0" + number + ".png"))
		clouds_large.append(sprite)
		
	for n in 6:
		var number:String = str(n+1)
		if len(number) < 2:
			number = str("0", number) 
		var sprite = load(str("res://textures/Cloud_S_0" + number + ".png"))
		clouds_small.append(sprite)
		
	for n in 20:
		var number:String = str(n+1)
		var sprite = load(str("res://textures/background/clouds/Cloud " + number + ".png"))
		clouds_all.append(sprite)
		
		
func loadBuildings():
	return
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
	
func getExplo(type:String, scale:float = 1.0, delay: float = 0.0):
	var explo
	match type:
		"basic": 
			explo = EXPLO_PART.instance()
		"radial": 
			explo = EXPLO_PART_RADIAL.instance()
		"wreck":
			explo = EXPLO_PART_W.instance()
		"shield":
			explo = EXPLO_PART_S.instance()
			
	explo.construct(scale, delay)
	return explo

func getPointInDir(dist, angle, origin):
	var x = round(origin.x + dist * cos(angle* PI / 180));
	var y = round(origin.y + dist * sin(angle* PI / 180));
	return Vector2(x, y)

func getWeaponBase(display):
	for n in weaponTemplates:
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
		2:
			weapon = Globals.weapon_missile.instance()
		3:
			weapon = Globals.weapon_aoe.instance()
		4:
			weapon = Globals.weapon_beam.instance()
		6:
			weapon = Globals.weapon_rail.instance()
		7:
			weapon = Globals.weapon_missile.instance()
		8:
			weapon = Globals.weapon_melee.instance()
		
	weapon.constructWpn(data)
	weapon.desc = data.desc
#	print(weapon.get_node("Sprites/Main").scale)
	return weapon

func load_new():
	print("load_new")
	
func load_weapons_csv():
#	load_new()
	print("load_weapons_csv")
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
			dict[header[21]] = int(csv[21])
			dict[header[22]] = float(csv[22])
			dict[header[23]] = float(csv[23])
			dict[header[24]] = float(csv[24])
			weaponTemplates.append(dict)

func getItemBase(display):
	for n in itemTemplates:
		if n.display == display:
			return instantiateAndConstructItem(n)
			
func instantiateAndConstructItem(pick):
	print("instantiateAndConstructItem ", pick.display)
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
	var dirPath = "res://resources/items/"
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
#	print("getPossibleWeaponMods")
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

	
func getSmokeNode(scale = 1):
	var smoke = SMOKE.instance()
	smoke.scale = Vector2(scale, scale)
	return smoke
	
func getFireSmokeNode(scale:float = 1, delay:float = 0.0):
	var fire = FIRESMOKE.instance()
	fire.construct(scale, delay)
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

func toggle_pause_and_menu():
	if PLAYER.ready == false:
		return
	
	isPaused = !isPaused
	get_tree().paused = !get_tree().paused
	curScene.get_node("UI/Pause_details").visible = !curScene.get_node("UI/Pause_details").visible
	curScene.get_node("UI/PauseSep").visible = !curScene.get_node("UI/PauseSep").visible
	
	
	if not isPaused:
		for item in PLAYER.get_node("Items").get_children():
			if item.type == 0:
				item.leave_pause()
#				item.subPanel_Stats.set("modulate", Color(1, 1, 1, 1))
#				item.subPanel_Stats.hide()
		for wpn in PLAYER.get_node("Mounts/A").get_children():
				wpn.leave_pause()
#				wpn.subPanel_Stats.set("modulate", Color(1, 1, 1, 1))
#				wpn.subPanel_Stats.hide()
	else:
		for item in PLAYER.get_node("Items").get_children():
			if item.type == 0:
				item.enter_pause()
#				item.subPanel_Stats.get_node("Timer").stop()
#				item.subPanel_Stats.get_node("Tween").stop_all()
#				item.subPanel_Stats.set("modulate", Color(1, 1, 1, 1))
		for wpn in PLAYER.get_node("Mounts/A").get_children():
				wpn.enter_pause()
#				wpn.subPanel_Stats.get_node("Timer").stop()
#				wpn.subPanel_Stats.get_node("Tween").stop_all()
#				wpn.subPanel_Stats.set("modulate", Color(1, 1, 1, 1))
				
		if PLAYER.aWeapon > -1:
			PLAYER.getActiveWeapon().subPanel_Stats.show()
		if PLAYER.aItem > -1:
			PLAYER.items[PLAYER.aItem].subPanel_Stats.show()

	
func getRecoilForce(minDmg, maxDmg, speed):
	return Vector2(round(pow((minDmg+maxDmg)*speed, 0.8)), 0)
	
func add_shockwave_at(pos):
	var shader = Globals.shock_shader.instance()
	shader.position = pos
	Globals.curScene.get_node("Projectiles").add_child(shader)

func add_poi_marker(target):
	curScene.get_node("UI/POI").add_indicator(target, PLAYER)
	
func remove_poi_marker(target):
	if "target_indicator" in target and target.target_indicator != null and is_instance_valid(target.target_indicator):
		target.target_indicator.queue_free()
	
func getRawDamage(minDmg, maxDmg, multi):
	return round(rng.randi_range(minDmg, maxDmg) * multi)
	
#func init_resolution():
#
#	var index:int = -1
#	for option in Globals.reso_options:
#		index += 1
#		var string = str(option.x, " x ", option.y)
#		UI.pause.res.add_item(string)
#		if Globals.SCREEN == option:
#			UI.pause.res.selected = index
#
#	index = -1
#	for i in Globals.zoom_options:
#		index += 1
#		UI.pause.zoom.add_item(str(i))
#		if Globals.ZOOM == Vector2(i, i):
#			UI.pause.zoom.selected = i
#
#	UI.pause._on_Resolution_item_selected(UI.pause.res.selected)
#	UI.pause._on_Zoom_item_selected(UI.pause.zoom.selected)
#	curScene._on_resolutionChange()
