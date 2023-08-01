extends Base_Unit
class_name Reward_Box

var display = "Reward Crate"
var cost:int
var loot = null

func _physics_process(delta):
	pass # Replace with function body.
	
func _ready():
	$ColNodes/Hover.connect("mouse_entered", self, "_on_mouse_entered")
	$ColNodes/Hover.connect("mouse_exited", self, "_on_mouse_exited")
	$ColNodes/Hover.connect("input_event", self, "_on_Reward_Box_input_event")
	$Sprite.material.set_shader_param("width", 0.0)
	
	loot = getLoot()
	loot.set_physics_process(false)
#	node.add_child(loot)

	$Debug.queue_free()

func setStats():
	maxHealth = 30
	
func updateDebugList():
	return

func updateAIList():
	return
	
func _on_mouse_entered():
#	print("mouse in")
	$Sprite.material.set_shader_param("width", 3.0)
	
func _on_mouse_exited():
#	print("mouse out")
	$Sprite.material.set_shader_param("width", 0.0)
	
func _on_Reward_Box_input_event(_viewport, event, _shape_idx):
	if  event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		if player.ressources >= cost:
			player.addRessources(-cost)
			kill()
	
func kill():
	spawnSelfLoot()
	.kill()
	
func spawnSelfLoot():
	loot.doInitUI()
	
	Globals.curScene.get_node("UI/LootNodes").add_child(loot.full_ui_box)
	loot.full_ui_box.rect_global_position = Vector2(global_position.x, global_position.y - 40)

	loot.UI_node.connect("mouse_entered", loot, "_on_ICONPANEL_mouse_entered")
	loot.UI_node.connect("mouse_exited", loot, "_on_ICONPANEL_mouse_exited")
	loot.UI_node.connect("gui_input", loot, "_on_ICONPANEL_mouseclick")	
	
	loot.subPanel_Stats.show()
	loot.show()
	
func setCost():
	cost = Globals.getRandomEntry([30, 40, 50, 60])

func getLoot():
	var options = ["Weapon", "Item"]
	var pick = options[Globals.rng.randi_range(0, len(options)-1)]
#	pick = "Weapon"
#	pick = "Item"

	match pick:
		"Weapon": loot = getWeaponLoot()
		"Item": loot = getItemLoot()
		
	loot.get_node("Sprite").scale = Vector2(1, 1)
	loot.get_node("Sprite").offset = Vector2(0, 0)
	loot.set_physics_process(false)
	loot.hide()
	return loot
	
func getItemLoot():
	var pointsRemain = 1
	var possibilites = Globals.getPossibleLoot_Items()
	var totalWeight:int = 0
	var pick = null
	for entry in possibilites:
		totalWeight += entry.weight
		
	var dice = Globals.rng.randi_range(1, totalWeight)
	var current = 1
	
#	print("rolled ", dice)	
	for entry in possibilites:
		current += entry.weight
#		print("now at ", current)
		if current >= dice:
#			print("picking")
			pointsRemain -= entry.cost
#			entry.hits += 1
#			entry.cost += 1
			var base = Globals.constructItem(entry.duplicate(true))
			base.initQuality()
			return base

func getWeaponLoot():
	var types = [1, 2, 4, 6]
	var type = types[Globals.rng.randi_range(0, len(types)-1)]
#	type = 1
	
	var base = Globals.getRandomBaseWeaponByType(type)
	base.initQuality()
	base.get_node("Sprite").texture = Globals.getTex(base.texture, 1)
	return base
