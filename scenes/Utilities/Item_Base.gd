extends Base_Entity
class_name Item_Base


#export(Resource) var item_input

var type:int
var display:String
var maxCharges:int
var remCharges:int
var cooldown:float
var baseCooldown:float
var texture
var trigger:String
var amount:int
var result = []

var canActivate = false
var selected = false
var isBeingUsed = false
var weapon = null

func constructNew(data):
	type = data.type
	faction = 0
	display = data.display
	desc = data.desc
	remCharges = data.charges
	maxCharges = data.charges
	cooldown = 0.0
	baseCooldown = data.cooldown
	texture = data.texture
	$Sprite.texture = Globals.getTex(data.texture, 0)
	amount = data.amount
	trigger = data.trigger
	result = data.result
	
	
#	item_input = load("res://ressources/item_health_up_shield_down.tres")
#	set_stats()
	
func set_stats():
	type = item_input.type
	faction = 0
	display = item_input.display
	desc = item_input.desc
	remCharges = item_input.charges
	maxCharges = item_input.charges
	cooldown = item_input.cooldown
	baseCooldown = item_input.cooldown
	texture = item_input.texture
	$Sprite.texture = Globals.getTex(item_input.texture, 0)
#	effects = data.effects
	
	

func _ready():
	pass
	
func doInitUI():
	if full_ui_box == null:
		full_ui_box = get_full_ui_box()
		UI_node = full_ui_box.get_node("Vbox/Core")
		subPanel_Stats = full_ui_box.get_node("Vbox/PanelItemStats")
	
func _physics_process(_delta):
	#print(cooldown)
	if baseCooldown != 0 and cooldown != 0:
		cooldown = max(cooldown - _delta, 0.0)
		setUICooldown()

func setUICooldown():
	if baseCooldown != 0:
		UI_node.get_node("CC/PC/CDProgress").value = cooldown/baseCooldown*100
		
func initCallMethodTrack(method, interval, start):
	var animation = Animation.new()
	animation.set_length(start + (interval * amount))
	animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(0, ".")
	
	for i in amount:
		var time = start + interval*(i+1)
#		$AnimationPlayer.get_animation("anim").track_insert_key(track_index, time, {"method" :method, "args" : []})
		animation.track_insert_key(0, time, {"method" :method, "args" : []})
		
		
	$AnimationPlayer.add_animation("anim", animation)
	
func inCooldown():
	return cooldown > 0
	
func hasChargesLeft():
	return remCharges > 0
	
func doUse():
#	print("doUse ", display)
	if inCooldown(): return
	if not hasChargesLeft(): return
	if isInActiveUse(): return
	consumeCharge()
	cooldown = baseCooldown
	isBeingUsed = true
	$AnimationPlayer.play("anim")
	
func doStopUse():
	isBeingUsed = false
	$AnimationPlayer.stop(true)
	
func doReset():
	cooldown = baseCooldown
	
func isInActiveUse():
	return isBeingUsed

func consumeCharge():
	remCharges -= 1
	var nodes = UI_node.get_node("CC/PC/VB/HB").get_children()
	nodes[remCharges].color = Color(1, 0, 0, 1)
	#print("charges-: ", remCharges, " / ", maxCharges)
	
func addCharge():
	if remCharges >= maxCharges: return
	
	remCharges += 1
	var nodes = UI_node.get_node("CC/PC/VB/HB").get_children()
	nodes[remCharges-1].color = Color(0, 1, 0, 1)
	#print("charges+: ", remCharges, " / ", maxCharges)	

func _on_AnimationPlayer_animation_finished(anim_name):
	isBeingUsed = false
	$AnimationPlayer.stop()
	resetState()
	
func resetState():
	pass

func getStatsPanel():
	var statsPanel = load("res://ui/PanelItemStats.tscn").instance()
	statsPanel.rect_position = Vector2(0, 0)
	statsPanel.get_node("VBox/MC_Title/Label").text = str(display)
	statsPanel.get_node("VBox/MC_Desc/Label").text = str(desc)
	
	fillQualityRows(statsPanel)
	fillStatsRows(statsPanel)
	return statsPanel

func fillQualityRows(statsPanel):
	statsPanel.get_node("VBox/MC_Qual/Vbox/Label").text = str("-- ", getQualityAsString(), " --")
	match quality: 
		-2: statsPanel.get_node("VBox/MC_Qual/Vbox/").set("modulate", "e92c00")
		-1: statsPanel.get_node("VBox/MC_Qual/Vbox/").set("modulate", "ffa100")
		1: statsPanel.get_node("VBox/MC_Qual/Vbox/").set("modulate", "bbe900")
		2: statsPanel.get_node("VBox/MC_Qual/Vbox/").set("modulate", "2cff00")
		
	for mod in mods:
		var newEntry = statsPanel.get_node("VBox/MC_Qual/Vbox/Label").duplicate() 
		statsPanel.get_node("VBox/MC_Qual/Vbox").add_child(newEntry)
		newEntry.show()
		newEntry.text = str(mod.name)
#		match n.type: 
#			"pct":
#				newEntry.text = str((n.effect * 100), " % ", n.name)
#			"flat":
#				newEntry.text = str(n.effect, " ", n.name)
	return statsPanel
		
func fillStatsRows(statsPanel):
	for n in effects:
#		print(n)
		if "isStat" in n:
#			print(n)
			if n.amount != 0:
#				print(n.prop)
#				print(n.amount)
				statsPanel.addEntry(n.prop, n.amount)
	return statsPanel
			
func initQuality():
	setQualityLevel()
	setQualityMods()
	applyQualityMods()
	
func setQualityLevel():
#	print(display)
	if quality!= -10: return
	var outcomes = [-2, -1, 0, 1, 2]
	var treshold = [2, 6, 15, 18, 20]
	var roll = Globals.rng.randi_range(1, treshold[len(treshold)-1])
	
	for i in len(treshold):
		if roll <= treshold[i]:
			quality = outcomes[i]
			return
	return

func setQualityMods():
	match quality: 
		-2:
			mods.append({"name": "Way less effective", "prop": "effectiveness", "effect": 0.85, "type": "pct"})
			if maxCharges: mods.append({"name": "Less charges", "prop": "charges", "effect": -1, "type": "flat"})
			elif baseCooldown: mods.append({"name": "Longer cooldown", "prop": "cooldown", "effect": 1.1, "type": "pct"})
		-1:
			mods.append({"name": "Slightly less effective", "prop": "effectiveness", "effect": 0.9, "type": "pct"})
		1:
			mods.append({"name": "Slightly more effective", "prop": "effectiveness", "effect": 1.1, "type": "pct"})
		2:
			mods.append({"name": "Way more effective", "prop": "effectiveness", "effect": 1.15, "type": "pct"})
			if maxCharges: mods.append({"name": "More charges", "prop": "charges", "effect": 1, "type": "flat"})
			elif baseCooldown: mods.append({"name": "Shorter cooldown", "prop": "cooldown", "effect": 0.9, "type": "pct"})
			

func applyQualityMods():
	for entry in mods:
		#print(entry)
		match entry.prop:
			"charges":
				maxCharges += entry.effect
				remCharges += entry.effect
			"cooldown":
				#cooldown *= entry.effect
				baseCooldown *= entry.effect
#			"effectiveness":
#				for n in effects:
#					if n.effect >= 0:
#						n.effect *= entry.effect
#					else:
#						n.effect *= 2-entry.effect
			"amount":
				for n in effects:
					if n.amount >= 0:
						n.amount *= entry.effect
					else:
						n.amount *= 2-entry.effect
			"aoe":
				for n in effects:
					if n.aoe >= 0:
						n.aoe *= entry.effect
					else:
						n.aoe *= 2-entry.effect
			"beamWidth":
				for n in effects:
						n.beamWidth *= entry.effect
			"damage":
				for n in effects:
						n.minDmg *= entry.effect
						n.maxDmg *= entry.effect
			
#	print(effects)
	for entry in effects:
		match entry.prop:
			"maxHealth": entry.amount = stepify(entry.amount, 1)
			"maxShield": entry.amount = stepify(entry.amount, 1)
			"maxSpeed": entry.amount = stepify(entry.amount, 1)
			"enginePower": entry.amount = stepify(entry.amount, 1)
			"shieldRegenTime": entry.amount = -stepify(entry.amount, 0.01)
			"shieldBreakTime": entry.amount = -stepify(entry.amount, 0.1)
			"agility": entry.amount = stepify(entry.amount, 0.01)
			"boostMaxCharge": entry.amount = stepify(entry.amount, 1)
			
#		print(effects)
		if entry.amount != 0:
#			if "amount" in entry: 
#				entry.amount = stepify(entry.amount, 1)
			if "minDmg" in entry: 
				entry.minDmg = stepify(entry.minDmg, 1)
			if "maxDmg" in entry: 
				entry.maxDmg = stepify(entry.maxDmg, 1)
			if "aoe" in entry: 
				entry.aoe = stepify(entry.aoe, 1)
			if "beamWidth" in entry:
				entry.beamWidth = stepify(entry.beamWidth, 1)
			
#	print(display)
#	print(getQualityAsString())
	#print("modified: ", effects[0])
#	print(baseCooldown)
		
func getQualityAsString():
	match quality:
		-10: return "Average quality"
		-2: return "Battered quality"
		-1: return "Poor quality"
		0: return "Average quality"
		1: return "Good quality"
		2: return "Outstanding quality"

func toggle():
	print("toggling ", display)
	selected = !selected
	if selected:
		UI_node.get_node("CC/PC").add_stylebox_override("panel", Globals.RED)
		if Globals.isPaused:
			subPanel_Stats.show()
		else:
			subPanel_Stats.showandfadeout()
	else:
		UI_node.get_node("CC/PC").add_stylebox_override("panel", Globals.BLACK)
		subPanel_Stats.get_node("Timer").stop()
		subPanel_Stats.get_node("Tween").stop_all()
		subPanel_Stats.set("modulate", Color(1, 1, 1, 1))
		subPanel_Stats.hide()
		
func makeInvisible():
	hide()
	
func needsTarget():
	return false
	
func setItemTarget(target):
	return false
	
func doUnloadBits():
	return
	
func get_class():
	return "Item"
		
func _on_ICONPANEL_mouseclick(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		print("_on_ICONPANEL_mouseclick: ", display)
		UI_node.get_node("CC/PC").add_stylebox_override("panel", Globals.BLACK)
		UI_node.disconnect("mouse_entered", self, "_on_ICONPANEL_mouse_entered")
		UI_node.disconnect("mouse_exited", self, "_on_ICONPANEL_mouse_exited")
		UI_node.disconnect("gui_input", self, "_on_ICONPANEL_mouseclick")
		Globals.PLAYER.addItem(self)

func getIconContainer():
	var node = Globals.ITEMENTRYCONT.instance()
	node.get_node("CC/PC/VB/Tex").texture = get_node("Sprite").texture
#	node.get_node("CC/PC/VB/Tex").rect_min_size = Vector2(80, 50) * 0.7
#	node.rect_min_size *= 0.8
	
	for n in maxCharges:
		var subnode = node.get_node("CC/PC/VB/HB/Charge").duplicate()
		node.get_node("CC/PC/VB/HB").add_child(subnode)
	node.get_node("CC/PC/VB/HB").get_child(0).queue_free()
	return node

func _on_AnimationPlayer_animation_started(anim_name):
	print("starting ", anim_name)
