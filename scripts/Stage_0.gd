extends Node2D
class_name Base_Level

onready var player = Globals.PLAYER

var ui

var spawner
var obj
var enemies = Array()

var level_type:int

func _ready():
	print("ready world")
	Globals.GAMESCREEN.cur_lvl_number = 1
	level_type = 1
#	Globals.GAMESCREEN.get_node("Menu_BG").hide()
	setupLevel()
#	Engine.time_scale = 0.25
#	$Player.position = Vector2(Globals.WIDTH/2, Globals.HEIGHT/2)
	
func setupLevel():
	set_stage_dimensions()
	set_boundary_red()
	create_background()
	set_cam_limit()
	#load_ui()
	set_various_settings()
	readyPlayer()
	positionCamera()
	$UI.showAIUI()
	$UI/Pause_details/MC/VBC/PC/HBC2/GFX_settings.connectResolutionChange()
#	Globals.init_resolution()
	Globals.PROJCONT = get_node("Projectiles")
	
	handleLevelStartZooming()
	
func set_various_settings():
	Globals.BASEGRAVITY = Vector2(0, 300)
	
func set_stage_dimensions():
	Globals.WIDTH = 8000
	Globals.HEIGHT = 2000
	Globals.ROADY = Globals.HEIGHT - 45
	Globals.MUDY = Globals.HEIGHT - 35
	
func createTestBG(): #forest bg	
	
	var layercount: int = -1
	var layers = ["Moon", "Station", "Sky", "Mountain_Back", "Mountain_Front", "Forest"]
	var adjust = [0, 0, 1, 1, 1, 1]
	
	for n in $BG/Para_Test_Forest.get_children():
		layercount += 1
		var element = n.get_child(0)
		if n.visible:
			print("adjusting layer: ", n.name)
			if adjust[layercount] == 1:
				element.centered = false
				n.motion_mirroring.x = n.get_child(0).texture.get_width()
				element.position.y = Globals.HEIGHT - element.texture.get_height() * element.scale.y
			else:
				element.centered = true
				element.position.x = Globals.WIDTH / 2
				element.position.y = 775
#				element.position.y = 500
				n.motion_offset.x = (Globals.WIDTH/2 * n.motion_scale.x) - Globals.WIDTH/2
		
	$BG/Para_Test_Forest.scroll_limit_begin = Vector2(-600, -600)
	$BG/Para_Test_Forest.scroll_limit_end = Vector2(Globals.WIDTH+600, Globals.HEIGHT+600)
	
func createTestBG_cities():
	
	var index = 0
	var layer:int = 4
	
	for n in $BG/Para_Test.get_children():
		index += 1
		if index > 1:
			var element = Sprite.new()
			element.texture = load(str("res://textures/background/cities/final_01/", str(layer), ".png"))
			element.scale.y = 1.2
			element.centered = false
			layer -= 1
			n.add_child(element)
		
	#		var leng:float = max(1.0, 1.0 / n.motion_scale.x)
	#		n.get_child(0).rect_size.x = Globals.WIDTH# * leng
	#		n.get_child(0).rect_position.x = 0 + Globals.WIDTH - n.get_child(0).rect_size.x
	#		n.get_child(0).rect_position.y = Globals.HEIGHT - n.get_child(0).texture.get_height() * n.get_child(0).rect_scale.y
			n.motion_mirroring.x = 2320
#			var city = n.get_child(0)
			
			element.position.y = Globals.HEIGHT - element.texture.get_height() * element.scale.y
#			n.get_child(0).position.y = Globals.HEIGHT - n.get_child(0).texture.get_height() * n.get_child(0).scale.y
		
	$BG/Para_Test.scroll_limit_begin = Vector2(-600, -600)
	$BG/Para_Test.scroll_limit_end = Vector2(Globals.WIDTH+600, Globals.HEIGHT+600)
	
func createParallax():
	var layer:int = 4
	
	for n in $BG/Para_Test.get_children():
		var city = Sprite.new()
		city.texture = load(str("res://textures/background/cities/final_01/", str(layer), ".png"))
		layer -= 1
		n.add_child(city)
		
	
	return
		
func colorParallax(baseColor:Color):
	
#	var color = Color(0.796875, 0.976197, 1)
#	var color = Color(1, 0.828125, 0.828125)

	var color = Color()
	color.r = baseColor.r
	color.g = baseColor.g
	color.b = baseColor.b
	color.a = baseColor.a
	
	var index = 0
	for n in $BG/Para_Test.get_children():
		index += 1
		if index > 1:
#			print("adjusting color")
			var sprite = n.get_child(0)
			sprite.self_modulate = color
#			color.r *= 0.4
#			color.g *= 0.9
#			color.b *= 0.9
			color.r *= 0.9
			color.g *= 0.4
			color.b *= 0.4
	
	
func create_background():
	
#	var color = Color(0.695313, 0.978577, 1)
	var color = Color(1, 0.695313, 0.695313)
	
	var c1 = Color(1, 0.695313, 0.695313)
#	createParallax()
	createTestBG()
	#colorParallax(color)
	createMainRect(color)
	createRoadMud() 
	#createBG_Mountains()
	#createBG_Plains()
#	placeClouds(Globals.WIDTH * Globals.HEIGHT / 200000)
#	placeMountains(Globals.WIDTH / 600, 1.4, $ParallaxLayer/Mount_Backmost/Pos)
	#placeCities()
	#placeObstacles()
	
	var i = 0
	
	for n in $BG/Para_Front.get_children():
		i += 1
		n.motion_scale.x = 0.3 + i*0.1
		
	i = 0
	for n in $BG/Para_Mount.get_children():
		i += 1
		n.motion_scale.x = 0.2 + i*0.05
		
func createBG_Mountains():
	
	var baseWidth = Globals.WIDTH
	
	var amount = 4
	
	for n in amount:
		var poly =  Polygon2D.new()
		poly.name = str("MountLayer", n)
		
		var width = Globals.rng.randi_range(1800, 2400)
		width = width * 0.7
		var height = width * 0.35
		var peak = width / Globals.rng.randi_range(8, 12) *  Globals.getRandomEntry([1, -1])
		
		var startPointX = baseWidth / (1+amount) * (n +1) - Globals.WIDTH * 0.4
		var points = PoolVector2Array()
		
#		print("h: ", Globals.HEIGHT)
		
		points.append(Vector2(startPointX, Globals.HEIGHT))
		points.append(Vector2(startPointX + width, Globals.HEIGHT))
#		points.append(Vector2((startPointX + startPointX+width)/2 + peak, Globals.HEIGHT - height))
		points.append(Vector2((startPointX + startPointX+width)/2 + peak + 5, Globals.HEIGHT - height))
		points.append(Vector2((startPointX + startPointX+width)/2 + peak - 5, Globals.HEIGHT - height))
		
		poly.polygon = points
		poly.color = Color(0.2, 0.6, 0.2, 1.0)
		poly.color = Color(0.326889, 0.713873, 0.753906)
	
		$BG/Para_Test/Backmost/Mountains.add_child(poly)
	
func createBG_Mountainsx():
	
	var layers:int = 4
	var baseWidth = Globals.WIDTH
	
	for n in layers:
		var poly =  Polygon2D.new()
		poly.name = str("MountLayer", n)
		
		var width = Globals.rng.randi_range(1800, 2400)
		width = width / 2
		var height = width * 0.4
		var peak = width / Globals.rng.randi_range(6, 14) *  Globals.getRandomEntry([1, -1])
		
		var startPointX = baseWidth / (1+layers) * (n +1)
		var points = PoolVector2Array()
		
#		print("h: ", Globals.HEIGHT)
		
		points.append(Vector2(startPointX, Globals.HEIGHT))
		points.append(Vector2(startPointX + width, Globals.HEIGHT))
#		points.append(Vector2((startPointX + startPointX+width)/2 + peak, Globals.HEIGHT - height))
		points.append(Vector2((startPointX + startPointX+width)/2 + peak + 5, Globals.HEIGHT - height))
		points.append(Vector2((startPointX + startPointX+width)/2 + peak - 5, Globals.HEIGHT - height))
		
		poly.polygon = points
		poly.color = Color(0.2, 0.6, 0.2, 1.0)
	
		$BG/Para_Mount.get_child(n).get_child(0).add_child(poly)
#		$BG/Para_Mount.get_child(n).motion_scale.x = float(0.9 - (0.15 * n))
			
	
func createBG_Plains():

	var indiHeight = [50, 50, 50, 50]
#	indiHeight = [100]
	
#	for n in indiHeight.size():
#		indiHeight[n] += 25
	var totalHeight:int
	for val in indiHeight:
		totalHeight += val
	var baseWidth = Globals.WIDTH
	var extendWidth = Globals.WIDTH * 0.2
	
	var heightNow:int = 0
	var layer:int = 0
		
	var shade:float = 0.7
#	var colors = [Color(shade, 0, 0, 1), Color(0, shade, 0, 1), Color(0, 0, shade, 1)]
	var color = Color(0.5, 1.0, 0.5, 1.0)
#	colors = [Color(0, shade, 0, 1)]
	
	for n in indiHeight:
		layer += 1
		var poly =  Polygon2D.new()
#		poly.name = str("Layer", layer)
		var points = PoolVector2Array()
		
		var startPos = Globals.HEIGHT - totalHeight + heightNow
		heightNow += n
#		print("start height for layer: ", layer, ": ", startPos)
		points.append(Vector2(-extendWidth, startPos))
		
		var mountainAmount = Globals.rng.randi_range(3, 5)
		
		for i in mountainAmount:
			var mountainPointHeight = Globals.rng.randi_range(n, n/2)
			if i % 2 != 0:
					mountainPointHeight *= -0.2
			var mountainPointX = baseWidth / (1+mountainAmount) * (i+1)
			var mountainPointXOffset = baseWidth / mountainAmount / Globals.rng.randi_range(8, 12) *  Globals.getRandomEntry([1, -1])
			
			points.append(Vector2(mountainPointX + mountainPointXOffset, startPos - mountainPointHeight))
			
#			print("placing at ", points[points.size()-1].x, ", height: ", mountainPointHeight)
		
		points.append(Vector2(baseWidth + extendWidth, startPos))
		points.append(Vector2(baseWidth + extendWidth, Globals.HEIGHT))
		points.append(Vector2(-extendWidth, Globals.HEIGHT))
		
		poly.polygon = points
		poly.color = color
		
		color.r *= 0.7
		color.g *= 0.8
		color.b *= 0.7
		
#		shade -= 0.2
#		if color.r > 0.1:
#			color.r = shade
#		elif color.g > 0.1:
#			color.g = shade
#		elif color.b > 0.1:
#			color.b = shade
		
		
		var targetNode:ParallaxLayer
		match layer:
			1:
				targetNode = $BG/Para_Front/Plains_A
			2:
				targetNode = $BG/Para_Front/Plains_B
			3:
				targetNode = $BG/Para_Front/Plains_C
			4:
				targetNode = $BG/Para_Front/Plains_D
			
		
		targetNode.add_child(poly)
#		targetNode.motion_scale.x = float(1.3 - (0.15 * layer))


func placeCities():
	
	var totalAmount = 6
#	totalAmount = 1
	
#	print(Globals.WIDTH)

		
	for n in totalAmount:
		
		var x:int = Globals.WIDTH / (totalAmount-1) * n
#		var x = Globals.WIDTH/2
		var y:int = Globals.ROADY
		var node = Node2D.new()
		node.name = str("City_", (n+1))
		
		var buildAmount:int
		var options:Array
		
		if n % 2 == 0:
			options = [1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5]
			buildAmount = Globals.getRandomEntry([8, 11])
			$BG/Para_Front/A.add_child(node)
			y -= 125
			node.modulate.a = .9
		else:
			options = [1, 2, 3, 4, 5, 6, 7, 8]
			buildAmount = Globals.getRandomEntry([5, 8])
			$BG/Para_Front/G.add_child(node)
			
		node.position = Vector2(x, y)
		
#		print("city", n+1, " base X: ", x)
#		print(x)
		
		var offsetX = 0
		var offsetX_left = 0
		var offsetX_right = 0
		
		for i in buildAmount:
		
#			print("building ", i+1, ", current offset:", offsetX)
			var count = i+1
			var sprite = Sprite.new()
			sprite.name = str("City_", n, "_", "Build_", count) 
			sprite.texture = load(str("res://textures/background/bg_build_0", Globals.getRandomEntryAndRemove(options), ".png"))
#			if count == 3:
#				sprite.texture = load(str("res://textures/background/skytest1.png"))
			var posY:int
			var scale:float
				
			if n % 2 == 0:
				scale = 1.2 - rand_range(0.15, 0.25)
			else:
				scale = 1.2 + rand_range(0.05, 0.15)
				
			scale -= 0.06 * i
#			scale = 1.0
			var spriteDim = sprite.texture.get_size() * scale
			sprite.scale = Vector2(scale, scale)

			var space = 30 * scale
			if i > 0:
#				print("sprite half width: ", spriteDim.x/2)
				if i % 2 == 0:
					offsetX_left += space
					offsetX_left += spriteDim.x
					offsetX = -offsetX_left + spriteDim.x/2
				else:
					offsetX_right += space
					offsetX_right += spriteDim.x
					offsetX = offsetX_right - spriteDim.x/2
			else:
				offsetX_left += spriteDim.x/2
				offsetX_right += spriteDim.x/2
				
				
			
			sprite.position.x = offsetX
#			print("building", i+1, " offsetX ", offsetX)
		
#			if (Globals.rng.randi_range(0, 1)):
#				sprite.flip_h = true
			
			node.add_child(sprite)
			sprite.position.y = -spriteDim.y/2# * scale
			
#			sprite.material = load("res://scenes/Shaders/Fog_Material.tres")

func handleLevelStartZooming():
	doZoom(0.1, Globals.ZOOM.x, 3.0)
#	doZoom(0.1, 2.0, 0.2)	
	
func get_class():
	return "Stage0"	

func set_boundary_red():
#	print("stage set_boundary_red")
	$Various/Boundary/DmgNormal/A.shape.a = Vector2(0, 0)
	$Various/Boundary/DmgNormal/A.shape.b = Vector2(Globals.WIDTH, 0)
	$Various/Boundary/DmgNormal/B.shape.a = Vector2(Globals.WIDTH, 0)
	$Various/Boundary/DmgNormal/B.shape.b = Vector2(Globals.WIDTH, Globals.MUDY)
	$Various/Boundary/DmgNormal/C.shape.a = Vector2(Globals.WIDTH, Globals.MUDY)
	$Various/Boundary/DmgNormal/C.shape.b = Vector2(0, Globals.MUDY)
	$Various/Boundary/DmgNormal/D.shape.a = Vector2(0, Globals.MUDY)
#	$Various/Boundary/DmgNormal/D.shape.b = Vector2(0, 0)
#
#	for n in $Various/Boundary/DmgNormal.get_children():
#		print(n.shape.a)
#		print(n.shape.b)
	
func _draw():
	draw_boundary()

func draw_boundary():
#	var thick = 3
#	draw_rect(Rect2(Vector2.ZERO, Vector2(Globals.WIDTH, Globals.MUDY)), Color(1, 0, 0, 1), false, thick, false)
	
	for n in $Various/Boundary/DmgNormal.get_children():
		draw_line(n.shape.a, n.shape.b, Color(1, 0, 0, 1), 10.0, false)
	
func addUnit(nodePath, unit):
	get_node(nodePath).add_child(unit)
	
func createMainRect(baseColor:Color):
	
#	$BG/CanvasLayer_Back.follow_viewport_enable = true
#	return
	var rect = TextureRect.new()
	rect.name = "TextureRect"
	#rect.rect_size = Vector2(Globals.WIDTH, Globals.HEIGHT)
	var tex = GradientTexture2D.new()
	tex.width = Globals.WIDTH
	tex.height = Globals.HEIGHT
#	tex.width = Globals.SCREEN.x
#	tex.height = Globals.SCREEN.y
	tex.fill_from = Vector2(0, 1)
	tex.fill_to = Vector2(0, 0)
	
	var grad = Gradient.new()
	
	var colors = PoolColorArray()
#	colors.append(Color(0.47, 0.7, 0.9, 1.0))
#	colors.append(Color(0.072784, 0.182446, 0.621094))
	colors.append(baseColor)
	colors.append(Color(0.072784, 0.182446, 0.621094))
	
	var floats = PoolRealArray()
	floats.append(0.1)
	floats.append(0.9)
	
	grad.offsets = floats
	grad.colors = colors
	tex.gradient = grad
	rect.texture = tex
	
	$BG/CanvasLayer_Back/MainRectPos.add_child(rect)
	
	return
	
	var totalAmount = 3
	
	for n in totalAmount:
		
		var x:int = Globals.WIDTH / (totalAmount-1) * n
		var y:int = Globals.ROADY
		var node = Node2D.new()
		node.name = str("City_", (n+1))
		node.modulate.a = .8
		node.position = Vector2(x, y)
		$BG/CanvasLayer_Back/MainRectPos.add_child(node)
		
		var options = [1, 2, 3, 4, 5, 6, 7, 8]
		var amount = Globals.getRandomEntry([6, 8])
		var offsetX = 0
		var offsetX_left = 0
		var offsetX_right = 0
		
		var scale:float = 3 + rand_range(0.3, 0.4)
			
		for i in amount:
		
#			print("building ", i+1, ", current offset:", offsetX)
			var count = i+1
			var sprite = Sprite.new()
			sprite.name = str("City_", n, "_", "Build_", count) 
			sprite.texture = load(str("res://textures/background/bg_build_0", Globals.getRandomEntryAndRemove(options), ".png"))
			
			var posY:int
				
			scale -= 0.05 * i
			var spriteDim = sprite.texture.get_size() * scale
			sprite.scale = Vector2(scale, scale * 1.1)

			var space = 30 * scale
			if i > 0:
#				print("sprite half width: ", spriteDim.x/2)
				if i % 2 == 0:
					offsetX_left += space
					offsetX_left += spriteDim.x
					offsetX = -offsetX_left + spriteDim.x/2
				else:
					offsetX_right += space
					offsetX_right += spriteDim.x
					offsetX = offsetX_right - spriteDim.x/2
			else:
				offsetX_left += spriteDim.x/2
				offsetX_right += spriteDim.x/2
				
			
			sprite.position.x = offsetX
			sprite.position.y = -spriteDim.y/2
			node.add_child(sprite)
	
	
func doZoom(startZ, endZ, time):
	var dur = time * Globals.mod
	Globals.ZOOM = Vector2(startZ, startZ)
	$Refs/Zoom_Tweener.interpolate_property($CamA, "zoom",
		Vector2(startZ, startZ), Vector2(endZ, endZ), dur,
		Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Refs/Zoom_Tweener.start()
	
	$Refs/Zoom_Tweener.connect("tween_all_completed", self, "setZoom", [Vector2(endZ, endZ)])
	
func setZoom(zoom):
	Globals.ZOOM = zoom
	$CamA.zoom = zoom

func set_cam_limit():
	$CamA.limit_left = -200 -1000
	$CamA.limit_top = -200 -1000
	$CamA.limit_top = 0
	$CamA.limit_right = Globals.WIDTH + 200 +1000
#	$CamA.limit_bottom = Globals.HEIGHT + 200 +1000
	$CamA.limit_bottom = Globals.HEIGHT# + 200 +1000
	
func readyPlayer():
	print("readyPlayer")
	$Player_Pos.add_child(player)
	if player.new:
		setPlayerUIConnections()
		player.new = false
		player.addStartingWeapons()
		player.addStartingItems()
#		var trans = RemoteTransform2D.new()
#		trans.name = "RemoteTransform"
#		player.add_child(trans)
#		trans.remote_path = "../../../CamA"
	player.position = Vector2(Globals.WIDTH/2, Globals.HEIGHT/2)
	player.position = Vector2(Globals.WIDTH/2, Globals.HEIGHT-400)
#	player.position = Vector2(Globals.WIDTH - 400, Globals.HEIGHT-400)
#	player.hide()
#	player.setInactive()
	player.doInit()
	player.setupDelayedWarpIn(1.0)
	
func positionCamera():
	$CamA.position = player.position
	
func setPlayerUIConnections():
		#print("connecting")
		player.connect("update_player_health", get_node("UI"), "_on_update_player_health")
		player.connect("update_player_materials", get_node("UI"), "_on_update_player_materials")
	
func load_ui():
	if has_node("UI"):
		$UI.resetMissionUI()
		$UI.init_pause_menu()
#		return
#
#	var ui = preload("res://ui/UI.tscn").instance()
#	add_child(ui)
#	Globals.UI = $UI
#	$UI.init_pause_menu()

func placeClouds(amount):
	$BG/Para_Front/Clouds_Back.modulate.a = 0.7
	$BG/Para_Front/Clouds_Mid.modulate.a = 0.85
	$BG/Para_Front/Clouds_Fore.modulate.a = 1.0
	
	var minY = 400
	var maxY = Globals.HEIGHT * 0.7
	var pxStep = floor(Globals.WIDTH*1.5/amount * 1.5)
	
	var all = amount
	
	for n in amount:
		all += 1
		var minX = (n+0)*pxStep
		var maxX = (n+1)*pxStep
		var x = range(minX,maxX)[randi()%range(minX,maxX).size()]
#		print(x)
		var y = range(minY,maxY)[randi()%range(minY,maxY).size()]
		
		var node = Node2D.new()
		var sprite = Sprite.new()
		node.add_child(sprite)
		
#		var rotation = Globals.rng.randi_range(-12, 12)
#		sprite.rotation_degrees = rotation
		
		node.position = Vector2(x, y)
		
		var pick:int
		var tex:Texture
		var scale:float
		
		tex = Globals.clouds_all[rand_range(0, len(Globals.clouds_all)-1)]
		scale = 1.4 + rand_range(.2, .3)
		if (Globals.rng.randi_range(0, 1) > 0.5):
			$BG/Para_Front/Clouds_Back/Pos.add_child(node)
		else:
			if (Globals.rng.randi_range(0, 1) > 0.4):
				$BG/Para_Front/Clouds_Mid/Pos.add_child(node)
			else:
				$BG/Para_Front/Clouds_Fore/Pos.add_child(node)
		
		if false:
			if (Globals.rng.randi_range(0, 1) > 0.5):
				$BG/Para_Front/Clouds_Back/Pos.add_child(node)
				tex = Globals.clouds_large[rand_range(0, len(Globals.clouds_large)-1)]
				scale = 0.4 + rand_range(.1, .15)
			else:
				n -= 1
				tex = Globals.clouds_small[rand_range(0, len(Globals.clouds_small)-1)]
				scale = 0.6 + rand_range(.1, .2)
				if (Globals.rng.randi_range(0, 1) > 0.4):
					$BG/Para_Front/Clouds_Mid/Pos.add_child(node)
				else:
					$BG/Para_Front/Clouds_Fore/Pos.add_child(node)
					scale += 0.2
			
		sprite.texture = tex
		sprite.scale = Vector2(scale, scale)
		if (Globals.rng.randi_range(0, 1)):
#			print("flipping")
			sprite.flip_h = true
#		else:
#			print("not flipping")
			
#	print("orginal: ", amount, ", actually: ", all)
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
		var sprite = mount.get_node("Sprites/Main")
		var size = 0.9 + 0.5 * randf() 
		sprite.scale = Vector2(size, size) * scaleMulti
		var spriteDim = sprite.texture.get_size() * size * scaleMulti
		mount.position = Vector2(x - spriteDim.x/2, y - spriteDim.y/2)
		print(mount.position.x)
		x+= interval
		if (Globals.rng.randi_range(0, 1)):
			mount.get_node("Sprites/Main").flip_h = true
			
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
	
	
func _xon_mouse_entered():
	print("i_xon_mouse_entered")
func _xon_mouse_exited():
	print("_xon_mouse_exited")
	

func createRoadMud():
#	$BG/CanvasLayer_Front.follow_viewport_enable = true
#	$ParallaxLayer/BackgroundA/Pos/TextureRect.rect_size = Vector2(Globals.WIDTH, Globals.HEIGHT)
	var road = getColorRect("road", "5f5f5f", Vector2(0, Globals.ROADY), Vector2(Globals.WIDTH, 15))
	$BG/Statics.add_child(road)
	var mud = getColorRect("brown", "867235", Vector2(0,  Globals.MUDY), Vector2(Globals.WIDTH, Globals.HEIGHT - Globals.MUDY))
	$BG/Statics.add_child(mud)
#	var mud = getColorRect("mud", "453a19", Vector2(0, Globals.MUDY), Vector2(Globals.WIDTH, 80))
#	$BG/ParallaxForeground/F/Pos.add_child(mud)
#	var forest = getTexRec("forest", "res://textures/Woods_01.png", Vector2(0, Globals.HEIGHT - 150), Vector2(Globals.WIDTH, 65))
#	$BG/ParallaxForeground/F/Pos.add_child(forest)
	

#	var brown = getColorRect("brown", "867235", Vector2(0, Globals.HEIGHT - 100), Vector2(Globals.WIDTH, 100))
#	$ParallaxLayer/BackgroundB/Pos.add_child(brown)
#	var road = getColorRect("road", "5f5f5f", Vector2(0, Globals.ROADY-5), Vector2(Globals.WIDTH, 15))
#	$ParallaxLayer/BackgroundB/Pos.add_child(road)
#	var mud = getColorRect("mud", "453a19", Vector2(0, Globals.MUDY), Vector2(Globals.WIDTH, 80))
#	$ParallaxLayer/BackgroundB/Pos.add_child(mud)
#	var forest = getTexRec("forest", "res://textures/Woods_01.png", Vector2(0, Globals.HEIGHT - 150), Vector2(Globals.WIDTH, 65))
#	$ParallaxLayer/Foreground/Pos.add_child(forest)
	
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
#	update()

func _on_Player_mouse_entered():
	print("m in")
	pass # Replace with function body.

func onPlayerWarpIn():
	player.doInitGear()

func _on_resolutionChange():
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_EXPAND, Globals.SCREEN)
	Globals.UI.get_node("Place/TopleftRighter/Difficulty/Vbox/Res/b").text = str(Globals.SCREEN)
	Globals.UI.get_node("Place/TopleftRighter/Difficulty/Vbox/Zoom/b").text = str("%.2f" % Globals.ZOOM.x)
