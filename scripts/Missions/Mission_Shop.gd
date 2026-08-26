extends Mission_Base
class_name Mission_Shop

func _ready():
	pass
	
func _physics_process(delta):
	pass
	
func set_base_props():
	code = "SHOP"
	title = "Shopping title"
	difficulty = 0
	reward = 0
	desc = "Shopping desc."
	
func mission_final_setup_self():
	do_init(100)
	do_setup()
	Globals.PLAYER.connect("_has_warped_in", self, "do_start_mission")

func do_init(init_time):
	maxTime = init_time
	timeRemain = init_time
	
func do_setup():
	spawnRewardCrates()

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
		Globals.curScene.get_node("Neutral_Units").add_child(node)
		#$Neutral_Units.add_child(node)
		box.do_init_unit()
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
