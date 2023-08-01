extends Item_Base
class_name Item_OrbitalStrikeBeam

var x = 0
var rota = 90
var facing = 1
var rotashift = -10

func _ready():
	var interval = 1
	var start = 0.5
	initCallMethodTrack("effector", interval, start)
	
func doUse():
	x = player.global_position.x
	rota = 90
	facing = 1
	
	if not (player.rotation_degrees <= 90 and player.rotation_degrees >= -90):
		facing = -1
	x += 300 * facing
	rota += rotashift * facing
	
	x = 1500
	.doUse()
	
func setQualityMods():
	match quality: 
		-2:
			mods.append({"name": "Way Less Lifetime", "prop": "lifetime", "effect": 0.8, "type": "pct"})
			mods.append({"name": "Beam more narrow", "prop": "beamWidth", "effect": 0.8, "type": "pct"})
			mods.append({"name": "Slightly Less Damage", "prop": "maxDmg", "effect": 0.8, "type": "pct"})
		-1:
			mods.append({"name": "Slightly less Lifetime", "prop": "lifetime", "effect": 0.9, "type": "pct"})
		1:
			mods.append({"name": "Slightly more Lifetime", "prop": "lifetime", "effect": 1.1, "type": "pct"})
		2:
			mods.append({"name": "Way more Lifetime", "prop": "lifetime", "effect": 1.2, "type": "pct"})
			mods.append({"name": "Beam more wide", "prop": "beamWidth", "effect": 1.2, "type": "pct"})
			mods.append({"name": "Slightly more Damage", "prop": "maxDmg", "effect": 1.2, "type": "pct"})
	
func effector():
	var dmgType = 0
	var faction = 0
#	var lifetime = 5
	var projNumber = 1
	
	var proj = Globals.BEAM.instance()
#	beam.construct(dmgType, faction, minDmg, maxDmg, beamLength, lifetime, projNumber, self, shooter)
	proj.construct(dmgType, faction, effects[0].minDmg, effects[0].maxDmg, Globals.HEIGHT*2, effects[0].beamWidth, 0, projNumber, self, false)
	Globals.curScene.get_node("Projectiles").add_child(proj)
	proj.isStatic = true
	proj.isPiercing = true
	
#	x += (Globals.rng.randi_range(150, 250) * facing)
	x += (Globals.rng.randi_range(100, 100) * facing)
#	print(x)
	
	proj.rotation_degrees = rota
	proj.global_position = Vector2(x, -100)
	proj.get_node("ColNodes/DmgNormal/ColShape").disabled = true
	proj.doBeamFadeIn()
	proj.initBeamSwipe()
#
#
#	$Tween.interpolate_property(self, "position:x",
#		position.x, position.x + 100, 1,
#		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#	$Tween.start()
