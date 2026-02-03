extends Base_Unit
class_name Reward_Box

var display = "Reward Crate"
var cost:int
var loot = null

func _physics_process(_delta):
	pass # Replace with function body.
	
func _ready():
	$ColNodes/Hover.connect("mouse_entered", self, "_on_mouse_entered")
	$ColNodes/Hover.connect("mouse_exited", self, "_on_mouse_exited")
	$ColNodes/Hover.connect("input_event", self, "_on_Reward_Box_input_event")
	$Sprites/Main.material.set_shader_param("width", 0.0)
	
	loot = getLoot()
	loot.set_physics_process(false)

	$ColorRect.material.set_shader_param("shake_rate", Globals.rng.randf_range(0.1, 0.9))

	$Debug.queue_free()

func setStats():
	maxHealth = 30
	
func updateDebugList():
	return

func update_debug_menu_entry():
	return
	
func _on_mouse_entered():
#	print("mouse in")
	$Sprites/Main.material.set_shader_param("width", 3.0)
	print($ColorRect.material.get_shader_param("shake_rate"))
	
func _on_mouse_exited():
#	print("mouse out")
	$Sprites/Main.material.set_shader_param("width", 0.0)
	
func _on_Reward_Box_input_event(_viewport, event, _shape_idx):
#	print("_on_Reward_Box_input_event")
	if  event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		if player.materials >= cost:
			player.add_resources(-cost)
			kill()
			get_tree().set_input_as_handled()
	
func kill():
	spawnSelfLoot()
	.kill()
	hide()
	
func spawnSelfLoot():
	loot.doInitUI()
	
	Globals.curScene.get_node("UI/LootNodes").add_child(loot.full_ui_box)
#	loot.full_ui_box.rect_global_position = Vector2(global_position.x -loot.full_ui_box.rect_size.x/2, global_position.y -40)
	loot.full_ui_box.rect_global_position = Vector2(global_position.x -loot.full_ui_box.rect_size.x/2, global_position.y -loot.full_ui_box.rect_size.y/2)
#	loot.full_ui_box.rect_global_position = Vector2(global_position.x -loot.full_ui_box.rect_size.x/2, global_position.y)
	
	loot.full_ui_box.get_node("Vbox/Core/PC").theme_type_variation = "panel_noBorder"
	
	loot.full_ui_box.connect("mouse_entered", loot, "_on_LOOTNODE_mouse_entered", [loot.full_ui_box])
	loot.full_ui_box.connect("mouse_exited", loot, "_on_LOOTNODE_mouse_exited", [loot.full_ui_box])
	loot.full_ui_box.connect("gui_input", loot, "_on_LOOTNODE_mouseclick", [loot.full_ui_box])
	
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
#		"Weapon": loot = getWeaponLoot("Laserlance")
		"Item": loot = getItemLoot()
#		"Item": loot = getItemLoot("Hail Support: Frigate")
#		"Item": loot = getItemLoot("Nearfield Deflector")
		
	loot.get_node("Sprites/Main").scale = Vector2(1, 1)
	loot.get_node("Sprites/Main").offset = Vector2(0, 0)
	loot.set_physics_process(false)
	loot.hide()
	return loot
	
func getItemLoot(name = ""):
	var base
	
	if name:
		base = Globals.getItemBase(name)
	else:
		var pointsRemain = 1
		var possibilites = Globals.getPossibleLoot_Items()
		var totalWeight:int = 0
	#	var pick = null
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
				base = Globals.instantiateAndConstructItem(entry.duplicate(true))
				break
				
	base.initQuality()
	return base

func getWeaponLoot(name = ""):
	var base
	
	if name:
		base = Globals.getWeaponBase(name)
	else:
		var types = [1, 2, 4, 6]
		var type = types[Globals.rng.randi_range(0, len(types)-1)]
	#	type = 1
		
		base = Globals.getRandomBaseWeaponByType(type)
		base.get_node("Sprites/Main").texture = Globals.getTex(base.texture, 1)
		
	base.initQuality()
	return base
