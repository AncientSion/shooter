extends Base_Level
class_name Intermission

func _ready():
	Globals.curLevel = 0

func setupLevel():
	.setupLevel()
	$UI.hideMissionUI()
	$UI.hideAIUI()
	player.addRessources(500)
	spawnRewardCrates()
	player.position = Vector2(Globals.WIDTH/2, Globals.HEIGHT*0.7)

func placeClouds(amount, scaleMulti, layer):
	return

func placeMountains(amount, scaleMulti, layer):
	return

func placeBuildings(amount, scaleMulti, layer):
	return

func instance_Spawner():
	return

func instance_MissionHandler():
	return

func setLevelDimensions():
	Globals.BASEGRAVITY = Vector2(0, 0)
	Globals.WIDTH = Globals.SCREEN.x
	Globals.HEIGHT = Globals.SCREEN.y
	Globals.ROADY = Globals.HEIGHT
	Globals.MUDY = Globals.HEIGHT

func get_class():
	return "Intermission"

func initHandlers():
	print("initHandlers")
	Globals.UI = $UI
	return

func createBackground():
	$HyperspacePart.position = Vector2(-200, Globals.SCREEN.y/2)
	$HyperspacePart.preprocess = 4
	$HyperspacePart.process_material.emission_box_extents.x = Globals.SCREEN.y/2 + 50

#	var b = getColorRect("b", Color(0, 0, 0, 1), Vector2(0, 0), Vector2(Globals.WIDTH, Globals.HEIGHT))
#	b.set_mouse_filter(2)
#	$ParallaxLayer/BackgroundA/Pos.add_child(b)
#	var a = getColorRect("a", "000c5e", Vector2(25, 25), Vector2(Globals.WIDTH-50, Globals.HEIGHT-50))
#	a.set_mouse_filter(2)
#	$ParallaxLayer/BackgroundB/Pos.add_child(a)

func createMainRect():
	var rect = TextureRect.new()
	rect.name = "TextureRect"
	#rect.rect_size = Vector2(Globals.WIDTH, Globals.HEIGHT)
	var tex = GradientTexture2D.new()
	tex.width = Globals.SCREEN.x
	tex.height = Globals.SCREEN.y
	tex.width = 2560
	tex.height = 1440
	tex.fill_from = Vector2(0, 1)
	tex.fill_to = Vector2(0, 0)

	var grad = Gradient.new()

	var colors = PoolColorArray()
	colors.append(Color(0, 0.015442, 0.085938))
	colors.append(Color(0, 0.048431, 0.269531))
	colors.append(Color(0, 0.015442, 0.085938))

	var floats = PoolRealArray()
	floats.append(0.0)
	floats.append(0.5)
	floats.append(1)

	grad.offsets = floats
	grad.colors = colors
	tex.gradient = grad
	rect.texture = tex

	$ParallaxLayer/BackgroundA/Pos.add_child(rect)
	rect.set_mouse_filter(2)
	
func handleLevelStartZooming():
	doZoom(0.1, 1, 1)
	
func setCameraLimits():
	$CamA.limit_left = 0
	$CamA.limit_top = 0
	$CamA.limit_right = Globals.SCREEN.x
	$CamA.limit_bottom = Globals.SCREEN.y

func onPlayerWarpIn():
	.onPlayerWarpIn()
	for n in player.items:
		n.set_physics_process(false)
		n.cooldown = 0.0
		n.setUICooldown()


func spawnRewardCrates():
	
	var xBorder = 200
	var width = Globals.SCREEN.x - xBorder*2
	var maxPerRow = 3
	var amount = 6

	var count = 0
	for n in amount:
		count += 1
		
		var x = xBorder + (width / (amount+1) * count)
		var y = 150

		var node = Position2D.new()
		var box = Globals.REWARD_BOX.instance()
		node.add_child(box)
		$Neutral_Units.add_child(node)
		box.setCost()
		box.addHealthLabel()
		box.get_node("ControlNodes/Health_Label/Label").text = str("Cost: ", box.cost)
		node.position = Vector2(x, y)
		box.kill()

func _on_resolutionChange():
	._on_resolutionChange()
	setCameraLimits()
	setLevelDimensions()
	createBackground()
	
