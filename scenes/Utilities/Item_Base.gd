#extends Node
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

var canActivate = false
var selected = false
var active = true
var isBeingUsed = false
var weapon:Weapon_Base = null

var checkTimer:float = 0.0

var targetProp:Base_Entity = null

func constructNew(data):
	type = data.type
	display = data.display
	desc = data.desc
	remCharges = data.charges
	maxCharges = data.charges
	cooldown = 0.0
	baseCooldown = data.cooldown
	texture = data.texture
	$Sprites/Main.texture = Globals.getTex(data.texture, 0)
	trigger = data.trigger
	result = data.result.duplicate(true)
	stock_result = data.result.duplicate(true)
	
	for n in result:
		if "type" in n:
			n.type = int(n.type)
		if "minDmg" in n:
			n.recoilForce = Globals.getRecoilForce(n.minDmg, n.maxDmg, n.speed)
		if "proc" in n:
			n.proc.type = int(n.proc.type)
			n.proc.recoilForce = Globals.getRecoilForce(n.proc.minDmg, n.proc.maxDmg, n.proc.speed)
	
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
	$Sprites/Main.texture = Globals.getTex(item_input.texture, 0)
#	result = data.result	

func _ready():
	for n in result:
		n.faction = faction
	doDisable()
	checkTimer = 1.0
	
func _physics_process(_delta):
	#print(cooldown)
	if baseCooldown != 0 and cooldown != 0:
		cooldown = max(cooldown - _delta, 0.0)
#		print(cooldown)
		setItemPanelCooldown()
		
func item_use_check_process(_delta):
	pass

func setItemPanelCooldown():
	if UI_node == null or baseCooldown == 0:
		return
	UI_node.get_node("PC/CDProgress").value = cooldown/baseCooldown*100
		
#func initCallMethodTrackx(method, interval, start):
#	var animation = Animation.new()
#	animation.set_length(start + (interval * amount))
#	animation.add_track(Animation.TYPE_METHOD)
#	animation.track_set_path(0, ".")
#
#	for i in amount:
#		var time = start + interval*(i+1)
##		$AnimationPlayer.get_animation("anim").track_insert_key(track_index, time, {"method" :method, "args" : []})
#		animation.track_insert_key(0, time, {"method" :method, "args" : []})
#
#	$AnimationPlayer.add_animation("anim", animation)
	
func initCallMethodTrack(method, interval, start):
	var animation = Animation.new()
#	animation.set_length(start + (interval * amount))
	animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(0, ".")
	
	var maxLength:float
	
	for effect in result:
		for i in effect.stacks:
			var time = start + interval*(i+1)
			maxLength = max(maxLength, time)
			animation.track_insert_key(0, time, {"method" :method, "args" : []})
		
	animation.set_length(maxLength)
#	print("len: ", maxLength)
		
	$AnimationPlayer.add_animation("anim", animation)
	
func inCooldown():
	return cooldown > 0
	
func hasChargesLeft():
	return remCharges > 0
	
func canUse():
	if inCooldown(): return false
	if not hasChargesLeft(): return false
	if isInActiveUse(): return false
	return true
	
func doUse():
#	print("doUse ", display)
	if not canUse(): return
	consumeCharge()
	cooldown = baseCooldown
	isBeingUsed = true
	$AnimationPlayer.play("anim")
	
func doStopUse():
	isBeingUsed = false
	$AnimationPlayer.stop(true)
	
func doDisable():
	active = false
	set_physics_process(false)
	
func doEnable():
	active = true  
	set_physics_process(true)

func doReset():
	cooldown = baseCooldown
	
func isInActiveUse():
	return isBeingUsed

func consumeCharge():
	remCharges -= 1
	print("using, charges left: ", remCharges)
	if UI_node != null:
		var nodes = UI_node.get_node("PC/VB/HB").get_children()
		nodes[remCharges].color = Color(1, 0, 0, 1)
	#print("charges-: ", remCharges, " / ", maxCharges)
	
func addCharge():
	if remCharges >= maxCharges: return
	
	remCharges += 1
	if UI_node != null:
		var nodes = UI_node.get_node("PC/VB/HB").get_children()
		nodes[remCharges-1].color = Color(0, 1, 0, 1)
	#print("charges+: ", remCharges, " / ", maxCharges)	

func _on_AnimationPlayer_animation_finished(anim_name):
	isBeingUsed = false
	$AnimationPlayer.stop()
	resetState()
	
func resetState():
	pass

func fillQualityRows():
	subPanel_Stats.get_node("VBox/MC_Qual/Vbox/Label").text = str("-- ", getQualityAsString(), " --")
	match quality: 
		-2: subPanel_Stats.get_node("VBox/MC_Qual/Vbox/").set("modulate", Globals.ORANGE)
		-1: subPanel_Stats.get_node("VBox/MC_Qual/Vbox/").set("modulate", Globals.YELLOW) 
		0: subPanel_Stats.get_node("VBox/MC_Qual/Vbox/").set("modulate", Globals.WHITE)
		1: subPanel_Stats.get_node("VBox/MC_Qual/Vbox/").set("modulate", Globals.LIGHTGREEN)
		2: subPanel_Stats.get_node("VBox/MC_Qual/Vbox/").set("modulate", Globals.GREEN)
		
	var i = 0
	for n in subPanel_Stats.get_node("VBox/MC_Qual/Vbox").get_children():
		if i >= 1:
			n.queue_free()
		i+= 1
		
		
	for mod in mods:
		var newEntry = subPanel_Stats.get_node("VBox/MC_Qual/Vbox/Label").duplicate() 
		subPanel_Stats.get_node("VBox/MC_Qual/Vbox").add_child(newEntry)
		newEntry.show()
		newEntry.text = str(mod.name)
#		match n.type: 
#			"pct":
#				newEntry.text = str((n.effect * 100), " % ", n.name)
#			"flat":
#				newEntry.text = str(n.effect, " ", n.name)
		
func fillStatsRows():
	for n in result:
#		print(n)
		if n.isStat == true:
#			print(n)
			if n.amount != 0:
#				print(n.prop)
#				print(n.amount)
				subPanel_Stats.addEntry(n.prop, n.amount)
				
func setQuality(level):
	quality = level
	mods = []
	
	for entry in stock_result:
		for key in entry:
			var value = entry[key]
			if key in result[0]:
				result[0][key] = value
	
	setQualityMods()
	applyQualityMods()
	fillQualityRows()
			
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
			mods.append({"name": "Way More effective", "prop": "effectiveness", "effect": 1.15, "type": "pct"})
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
			"effectiveness":
				for n in result:
					if n.isStat == true:
						if n.amount >= 0:
							n.amount *= entry.effect
						else:
							n.amount *= 2-entry.effect
			"amount":
				for n in result:
					if n.amount >= 0:
						n.amount *= entry.effect
					else:
						n.amount *= 2-entry.effect
			"aoe":
				for n in result:
					if n.aoe >= 0:
						n.aoe *= entry.effect
					else:
						n.aoe *= 2-entry.effect
			"beamWidth":
				for n in result:
						n.beamWidth *= entry.effect
			"damage":
				for n in result:
						n.minDmg *= entry.effect
						n.maxDmg *= entry.effect
			"lifetime":
				for n in result:
						n.lifetime *= entry.effect
			
#	print(result)
	for entry in result:
		if entry.isStat == true:
			match entry.prop:
				"maxHealth": entry.amount = stepify(entry.amount, 1)
				"maxShield": entry.amount = stepify(entry.amount, 1)
				"maxSpeed": entry.amount = stepify(entry.amount, 1)
				"enginePower": entry.amount = stepify(entry.amount, 1)
				"shieldRegenTime": entry.amount = -stepify(entry.amount, 0.01)
				"shieldBreakTime": entry.amount = -stepify(entry.amount, 0.1)
				"agility": entry.amount = stepify(entry.amount, 0.01)
				"boostMaxCharge": entry.amount = stepify(entry.amount, 1)
			
#		print(result)
		else:
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
	#print("modified: ", result[0])
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
	selected = !selected
	print("toggling ", display, " #", id, ", now: ", selected)
	if selected:
		UI_node.get_node("PC").theme_type_variation = "panel_magenta_border"
		if Globals.isPaused:
			subPanel_Stats.show()
		else:
			subPanel_Stats.showandfadeout()
	else:
		UI_node.get_node("PC").theme_type_variation = "Panel_Inner"
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

func get_class():
	return "Item"
		
func _on_LOOTNODE_mouseclick(event, loot_ui_node):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		print("_on_LOOTNODE_mouseclick: ", display)
		loot_ui_node.add_stylebox_override("panel", null)
		loot_ui_node.disconnect("mouse_entered", self, "_on_LOOTNODE_mouse_entered")
		loot_ui_node.disconnect("mouse_exited", self, "_on_LOOTNODE_mouse_exited")
		loot_ui_node.disconnect("gui_input", self, "_on_LOOTNODE_mouseclick")
		Globals.PLAYER.addItem(self)
		doEnable()

func getIconContainer():
	var node = Globals.ITEMENTRYCONT.instance()
	node.get_node("PC/VB/Tex").texture = get_node("Sprites/Main").texture
	
	for n in maxCharges:
		var subnode = node.get_node("PC/VB/HB/Charge").duplicate()
		node.get_node("PC/VB/HB").add_child(subnode)
	node.get_node("PC/VB/HB").get_child(0).queue_free()
	return node

func _on_AnimationPlayer_animation_started(anim_name):
	print("starting ", anim_name)
	
func scaleDmg(multiplier):
	for n in result:
		n.minDmg *= multiplier
		n.maxDmg *= multiplier

func doUnload():
	pass
