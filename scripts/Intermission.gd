extends Base_Level
class_name Intermission

func _ready():
	Globals.GAMESCREEN.cur_lvl_number = 0
	level_type = 0

func setupLevel():
	.setupLevel()
	$UI.hideMissionUI()
	$UI.hideAIUI()
	player.add_resources(500)
	spawnRewardCrates()
	player.position = Vector2(Globals.WIDTH/2, Globals.HEIGHT*0.7)
#	print(player.position)

func set_stage_dimensions():
	Globals.BASEGRAVITY = Vector2(0, 0)
	Globals.WIDTH = Globals.SCREEN.x
	Globals.HEIGHT = Globals.SCREEN.y
	Globals.ROADY = Globals.HEIGHT
	Globals.MUDY = Globals.HEIGHT

func createRoadMud():
	return

func placeClouds(amount):
	return

func placeMountains(amount, scaleMulti, layer):
	return

func placeBuildings():
	return

func instance_Spawner():
	return

func instance_MissionHandler():
	return

#func set_boundary_red():
#	$Various/Boundary/DmgNormal/A.shape.a = Vector2(0, 0)
#	$Various/Boundary/DmgNormal/A.shape.b = Vector2(Globals.WIDTH, 0)
#	$Various/Boundary/DmgNormal/B.shape.a = Vector2(Globals.WIDTH, 0)
#	$Various/Boundary/DmgNormal/B.shape.b = Vector2(Globals.WIDTH, Globals.HEIGHT)
#	$Various/Boundary/DmgNormal/C.shape.a = Vector2(Globals.WIDTH, Globals.HEIGHT)
#	$Various/Boundary/DmgNormal/C.shape.b = Vector2(0, Globals.HEIGHT)
#	$Various/Boundary/DmgNormal/D.shape.a = Vector2(0, Globals.HEIGHT)
#	$Various/Boundary/DmgNormal/D.shape.b = Vector2(0, 0)

func set_boundary_red(): 
#	print("intermission set_boundary_red")
	$Various/Boundary/DmgNormal/A.shape.a = Vector2(0, 0)
	$Various/Boundary/DmgNormal/A.shape.b = Vector2(Globals.SCREEN.x, 0)
	$Various/Boundary/DmgNormal/B.shape.a = Vector2(Globals.SCREEN.x, 0)
	$Various/Boundary/DmgNormal/B.shape.b = Vector2(Globals.SCREEN.x, Globals.SCREEN.y - 10)
	$Various/Boundary/DmgNormal/C.shape.a = Vector2(Globals.SCREEN.x, Globals.SCREEN.y - 10)
	$Various/Boundary/DmgNormal/C.shape.b = Vector2(0, Globals.SCREEN.y - 10)
	$Various/Boundary/DmgNormal/D.shape.a = Vector2(0, Globals.SCREEN.y - 10)
	$Various/Boundary/DmgNormal/D.shape.b = Vector2(0, 0)
	
#	for n in $Various/Boundary/DmgNormal.get_children():
#		print(n.shape.a)
#		print(n.shape.b)

func get_class():
	return "Intermission"
	
func createBG_Plains():
	return
func createBG_Mountains():
	return

func create_background():
	createMainRect(Color())
	
	$HyperspacePart.position = Vector2(-100, Globals.HEIGHT/2)
	$HyperspacePart.process_material.emission_box_extents.y = Globals.HEIGHT/2 + 100
	
	#BG/Para_Test.queue_free()

#	var b = getColorRect("b", Color(0, 0, 0, 1), Vector2(0, 0), Vector2(Globals.WIDTH, Globals.HEIGHT))
#	b.set_mouse_filter(2)
#	$ParallaxLayer/BackgroundA/Pos.add_child(b)
#	var a = getColorRect("a", "000c5e", Vector2(25, 25), Vector2(Globals.WIDTH-50, Globals.HEIGHT-50))
#	a.set_mouse_filter(2)
#	$ParallaxLayer/BackgroundB/Pos.add_child(a)

func createMainRect(baseColor:Color):
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

	$BG/CanvasLayer_Back/MainRectPos.add_child(rect)
#	$BG/Parallax_Clouds/MainRectPos.add_child(rect)
	rect.set_mouse_filter(2)
	
func handleLevelStartZooming():
	doZoom(0.1, 1, 1)
	
func set_cam_limit():
	$CamA.limit_left = -200
	$CamA.limit_top = -200
	$CamA.limit_right = Globals.SCREEN.x + 200
	$CamA.limit_bottom = Globals.SCREEN.y + 200
	$CamA.limit_left = 0
	$CamA.limit_top = 0
	$CamA.limit_right = Globals.SCREEN.x
	$CamA.limit_bottom = Globals.SCREEN.y

func onPlayerWarpIn():
	.onPlayerWarpIn()
	for n in player.items:
		n.set_physics_process(false)
		n.cooldown = 0.0
		n.setItemPanelCooldown()

func spawnRewardCrates():
	var xBorder = 150
	var width = Globals.SCREEN.x - xBorder*2
	var maxPerRow = 3
	var amount = 4

	var count = 0
	for n in amount:
		count += 1
		
		var tPos:Vector2 = getBoxPos(count)
		
		var x = xBorder + (width / (amount+1) * count)
		var y = 300

		var node = Position2D.new()
		var box = Globals.CURRENCY_BOX.instance()
		node.add_child(box)
		$Neutral_Units.add_child(node)
		box.setCost()
#		box.addHealthLabel()
#		box.get_node("ControlNodes/Health_Label/Label").text = str("Cost: ", box.cost)
		node.position = tPos
#		box.kill()


		var label = Globals.TEXT_LABEL.instance()
		label.name = "Cost_Label"
		label.offset = Vector2(0, 0)
		label.rect_position.y = 75
		label.get_node("CenterContainer/Label").text = str(box.cost)
		box.get_node("ControlNodes").add_child(label)


func getBoxPos(index):
	
	var xBorder = 150
	var width = Globals.SCREEN.x - xBorder*2
	var maxPerRow = 3
	var amount = 4

	var x = xBorder + (width / (amount+1) * index)
	var y = 300
	
	return Vector2(x, y)
#
func _on_resolutionChange():
	
	var oldRes = Globals.SCREEN
	
	._on_resolutionChange()
	set_cam_limit()
	set_boundary_red()
	create_background()
	
	reposLoot()
	
func reposLoot():
	
	var xBorder = 150
	var width = Globals.SCREEN.x - xBorder*2
	var maxPerRow = 3
	var amount = 6

	var count = 0
	for node in $Neutral_Units.get_children():
		count += 1
		
		var x = xBorder + (width / (amount+1) * count)
		var y = 150
		var n = node.get_child(0)
		node.position = getBoxPos(count)
#		Vector2(x, y)
		if n.loot.full_ui_box != null:
			n.loot.full_ui_box.rect_global_position = Vector2(n.global_position.x -n.loot.full_ui_box.rect_size.x/2 , n.global_position.y -n.loot.full_ui_box.rect_size.y/2)
	
#		print("Box ", count, ", position: ", node.position)
		
	
#	var newRes = Globals.SCREEN
#
#	var playerpos = player.global_position
#
#	player.global_position = playerpos / newRes * oldRes
		
		
func draw_boundary():
	var thick = 3
	draw_rect(Rect2(Vector2(1, 1), Vector2(Globals.SCREEN.x, Globals.SCREEN.y -5)), Color(1, 0, 0, 1), false, thick, false)
