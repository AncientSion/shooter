extends Node2D
class_name Base_Level

onready var player = Globals.PLAYER

var ui
var pause

var spawner
var obj
var enemies = Array()

func _ready():
	print("ready world")
	Globals.curLevel = 1
	setupLevel()
#	$Player.position = Vector2(Globals.WIDTH/2, Globals.HEIGHT/2)
	
func setupLevel():
	setLevelDimensions()
	setCameraLimits()
	loadUI()
	loadPause()
	createMainRect()
	createBackground() 
	placeClouds(Globals.WIDTH * Globals.HEIGHT / 600000, 1, $ParallaxLayer/Clouds/Pos)
	placeClouds(Globals.WIDTH * Globals.HEIGHT / 600000, 1, $ParallaxLayer/Cloud_Backmost/Pos)
	placeMountains(Globals.WIDTH / 600, 1.3, $ParallaxLayer/Mount_Backmost/Pos)
	placeBuildings(Globals.WIDTH / 1200, 0.9, $ParallaxLayer/Mount_Midmost/Pos)
	placeObstacles()
	readyPlayer()
	positionCamera()
	initHandlers()
	handleLevelStartZooming()
	
	$UI.showMissionUI()
	$UI.showAIUI()
	
	Globals.SCREEN = Vector2(2560, 1440)
#	setZoom(Vector2(1.33, 1.33))
	
	_on_resolutionChange()



func handleLevelStartZooming():
	doZoom(0.1, 1.0, 0)

	
func initHandlers():
	print("initHandlers")
	Globals.UI = $UI
	Globals.handler_mission.doInit()
	Globals.handler_spawner.doInit()
	
func get_class():
	return "Stage0"
	
func setLevelDimensions():
	Globals.BASEGRAVITY = Vector2(0, 250)
#	Globals.BASEGRAVITY = Vector2(0, 0)
	Globals.DIFFICULTY = 10
	Globals.WIDTH = 4000
	Globals.HEIGHT = 2800
	Globals.ROADY = Globals.HEIGHT - 45
	Globals.MUDY = Globals.HEIGHT - 35
	
#	Globals.WIDTH = Globals.SCREEN.x
#	Globals.HEIGHT = Globals.SCREEN.y
#	Globals.ROADY = Globals.HEIGHT
#	Globals.MUDY = Globals.HEIGHT


	$Various/Boundary/East/A.shape.a = Vector2(0, 0)
	$Various/Boundary/East/A.shape.b = Vector2(Globals.WIDTH, 0)
	$Various/Boundary/East/B.shape.a = Vector2(Globals.WIDTH, 0)
	$Various/Boundary/East/B.shape.b = Vector2(Globals.WIDTH, Globals.HEIGHT)
	$Various/Boundary/East/C.shape.a = Vector2(Globals.WIDTH, Globals.HEIGHT)
	$Various/Boundary/East/C.shape.b = Vector2(0, Globals.HEIGHT)
	$Various/Boundary/East/D.shape.a = Vector2(0, Globals.HEIGHT)
	$Various/Boundary/East/D.shape.b = Vector2(0, 0)

	
func addUnit(nodePath, unit):
	get_node(nodePath).add_child(unit)
	
func createMainRect():
#	return
	var rect = TextureRect.new()
	rect.name = "TextureRect"
	#rect.rect_size = Vector2(Globals.WIDTH, Globals.HEIGHT)
	var tex = GradientTexture2D.new()
	tex.width = Globals.WIDTH
	tex.height = Globals.HEIGHT
	tex.fill_from = Vector2(0, 1)
	tex.fill_to = Vector2(0, 0)
	
	var grad = Gradient.new()
	
	var colors = PoolColorArray()
	colors.append("0f113b")
	colors.append("090c5b")
#	colors.append("547b3c")
#	colors.append("5eacab")
#	colors.append("2e6ba5")
#	colors.append("7b643c")
#	colors.append("875eac")
#	colors.append("3a2ea5")
	
	var floats = PoolRealArray()
	floats.append(0.5)
	floats.append(0.9)
	
#	floats.append(0.15)
#	floats.append(0.5)
#	floats.append(1)
	
	grad.offsets = floats
	grad.colors = colors
	tex.gradient = grad
	rect.texture = tex
	
	$ParallaxLayer/BackgroundA/Pos.add_child(rect)

	
	
func doZoom(startZ, endZ, time):
	var dur = time * Globals.mod
	Globals.ZOOM = Vector2(startZ, startZ)
	$Tween.interpolate_property($CamA, "zoom",
		Vector2(startZ, startZ), Vector2(endZ, endZ), dur,
		Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	setZoom(Vector2(endZ, endZ))
	player.doWarpIn()
	
func setZoom(zoom):
	Globals.ZOOM = zoom
	$CamA.zoom = zoom
	Globals.UI.get_node("Place/TopleftRighter/Diffi/Vbox/HBox4/Label2").text = str("%.2f" % Globals.ZOOM.x)

func setCameraLimits():
	$CamA.limit_left = -200
	$CamA.limit_top = -200
	$CamA.limit_right = Globals.WIDTH + 200
	$CamA.limit_bottom = Globals.HEIGHT + 200
	
func readyPlayer():
	print("readyPlayer")
	$Player_Pos.add_child(player)
	player.setInactive()
	if player.new:
		setPlayerUIConnections()
		player.new = false
		player.addStartingWeapons()
		player.addStartingItems()
		var trans = RemoteTransform2D.new()
		trans.name = "RemoteTransform"
		player.add_child(trans)
		trans.remote_path = "../../../CamA"
	player.position = Vector2(Globals.WIDTH/2, Globals.HEIGHT/2)
	player.doInit()
	
func positionCamera():
	$CamA.position = player.position
	
func setPlayerUIConnections():
		#print("connecting")
		player.connect("updatePlayerHP", get_node("UI"), "_on_updatePlayerHP")
		player.connect("updateShieldCooldown", get_node("UI"), "_update_shieldBreakCooldown")
		player.connect("updatePlayerRes", get_node("UI"), "_on_updatePlayerRes")
	
func loadUI():
	if has_node("UI"):
		$UI.resetMissionUI()
		return
	ui = preload("res://ui/UI.tscn")
	add_child(ui.instance())
	
func loadPause():
	return
	if has_node("Pause"):
		return
	pause = preload("res://ui/Pause.tscn")
	add_child(pause.instance())

func placeClouds(amount, scaleMulti, layer):
	var minY = 250
	var maxY = 900
	var pxStep = floor(Globals.WIDTH/amount)
	
	for n in amount:
		var minX = (n+0)*pxStep
		var maxX = (n+1)*pxStep
		var x = range(minX,maxX)[randi()%range(minX,maxX).size()]
		var y = range(minY,maxY)[randi()%range(minY,maxY).size()]
		var pick = rand_range(0, len(Globals.clouds)-1)
		var cloud = Globals.clouds[pick].instance()
		layer.add_child(cloud)
		#var spriteDim = cloud.get_child(0).texture.get_size()
		
		var size = 3 + 1.5 * randf()
		var rotation = rand_range(-12, 12)
		
		cloud.position = Vector2(x, y)
		cloud.scale = Vector2(size, size) * scaleMulti
		cloud.rotation_degrees = rotation
		
		if (Globals.rng.randi_range(0, 1)):
			cloud.get_node("Sprite").flip_h = true

func placeMountains2(amount, scaleMulti, layer):
	var y = 1400
	var space = 300
	var minX = space
	var maxX = Globals.WIDTH - space
	var width = maxX - minX
	var interval = width / (amount-1)
	var x = space
	print("placing ", amount, " mounts")
	print("space ", space)
	print("totalwidth ", width)
	print("interval ", interval)
	for n in amount:
#		print(x)
#		if Globals.rng.randi_range(0, 2) == 0: continue
		var mount = Globals.mountain.instance()
		layer.add_child(mount)
		var sprite = mount.get_node("Sprite")
		var size = 0.9 + 0.5 * randf() 
		sprite.scale = Vector2(size, size) * scaleMulti
		var spriteDim = sprite.texture.get_size() * size * scaleMulti
		mount.position = Vector2(x - spriteDim.x/2, y - spriteDim.y/2)
		print(mount.position.x)
		x+= interval
		if (Globals.rng.randi_range(0, 1)):
			mount.get_node("Sprite").flip_h = true
			
func placeMountains(amount, scaleMulti, layer):
	#scaleMulti = 1
	var y = Globals.HEIGHT - 100
	var space = 450
	var minX = space
	var maxX = Globals.WIDTH - space
	var width = maxX - minX
	var interval = width / (amount-1)
	var x = space
#	print("placing ", amount, " mounts")
#	print("space ", space)
#	print("totalwidth ", width)
#	print("interval ", interval)
	for n in amount:
		#print(x)
		if Globals.rng.randi_range(0, 2) == 0: continue
		var sprite = Sprite.new()
		layer.add_child(sprite)
		sprite.name = "Mount"
		sprite.texture = load("res://textures/mountain_L_01.png")
		var size = 0.9 + 0.5 * randf() 
		sprite.scale = Vector2(size, size) * scaleMulti
		var spriteDim = sprite.texture.get_size() * size * scaleMulti
		spriteDim.x = 0
		sprite.position = Vector2(x - spriteDim.x/2, y - spriteDim.y/2)
#		print(sprite.position.x)
		x+= interval
		if (Globals.rng.randi_range(0, 1)):
			sprite.flip_h = true
			
func placeObstacles():
	var rock = Globals.ROCK.instance()
	Globals.curScene.get_node("Neutral_Units").add_child(rock)
	rock.setNeutral()
	rock.doInit()
	rock.position = Vector2(1000, 800)
	
func placeBuildings(amount, scaleMulti, layer):
	var y = Globals.HEIGHT - 120
	var space = 350
	var minX = space
	var maxX = Globals.WIDTH - space
	var width = maxX - minX
	var interval = width / (amount-1)
	var x = space
#	print("placing ", amount, " buildings")
#	print("space ", space)
#	print("totalwidth ", width)
#	print("interval ", interval)
	for n in amount:
		var sprite = Sprite.new()
		layer.add_child(sprite)
		sprite.name = "City"
		sprite.texture = load("res://textures/background/buildingBlock2.png")
		sprite.scale = Vector2(scaleMulti, scaleMulti)
		var spriteDim = sprite.texture.get_size() * sprite.scale.x
		sprite.position = Vector2(x - spriteDim.x/2, y - spriteDim.y/2)
		x+= interval
		if (Globals.rng.randi_range(0, 1)):
			sprite.flip_h = true

			
#	for n in amount:
#		for i in 4:
#			var sprite = Sprite.new()
#			layer.add_child(sprite)
#			sprite.name = str("Building_", n, "_", i)
#			sprite.texture = load(str("res://textures/background/building_0", Globals.rng.randi_range(1, 6), ".png"))
#			sprite.scale = Vector2(scaleMulti, scaleMulti)
#			var spriteDim = sprite.texture.get_size() * sprite.scale.x
#			sprite.position = Vector2(x - spriteDim.x/2 + (i*70), y - spriteDim.y/2 + Globals.rng.randi_range(0, 20))
#			if (Globals.rng.randi_range(0, 1)):
#				sprite.flip_h = true
#
#		x+= interval
			
	
	
func _xon_mouse_entered():
	print("i_xon_mouse_entered")
func _xon_mouse_exited():
	print("_xon_mouse_exited")
	

func createBackground():
#	$ParallaxLayer/BackgroundA/Pos/TextureRect.rect_size = Vector2(Globals.WIDTH, Globals.HEIGHT)
	var brown = getColorRect("brown", "867235", Vector2(0, Globals.HEIGHT - 100), Vector2(Globals.WIDTH, 100))
	$ParallaxLayer/BackgroundB/Pos.add_child(brown)
	var road = getColorRect("road", "5f5f5f", Vector2(0, Globals.ROADY-5), Vector2(Globals.WIDTH, 15))
	$ParallaxLayer/BackgroundB/Pos.add_child(road)
	var mud = getColorRect("mud", "453a19", Vector2(0, Globals.MUDY), Vector2(Globals.WIDTH, 80))
	$ParallaxLayer/BackgroundB/Pos.add_child(mud)
	var forest = getTexRec("forest", "res://textures/Woods_01.png", Vector2(0, Globals.HEIGHT - 150), Vector2(Globals.WIDTH, 65))
	$ParallaxLayer/Foreground/Pos.add_child(forest)
	
func getColorRect(name, color, position, size):
	var node = ColorRect.new()
	node.name = name
	node.color = color
	node.rect_position = position
	node.rect_size = size
	return node
	
func getTexRec(name, source, position, size):
	var node = TextureRect.new()
	node.name = name
	node.texture = load(source)
	node.rect_position = position
	node.rect_size = size
	node.expand = true
	node.stretch_mode = 2
	return node
	
func _physics_process(delta):
	Globals.MOUSE = get_global_mouse_position();

func _on_Player_mouse_entered():
	print("m in")
	pass # Replace with function body.

func onPlayerWarpIn():
	player.doInitGear()

func _on_resolutionChange():
	$UI/Place/TopleftRighter/Diffi/Vbox/HBox3/Label2.text = str(Globals.SCREEN)
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_EXPAND, Globals.SCREEN)
