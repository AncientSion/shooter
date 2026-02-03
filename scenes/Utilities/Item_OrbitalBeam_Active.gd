extends Item_Base
class_name Item_OrbitalBeam_Active

var x:int = 0
var rota:int
var facing:int = 1
var rotashift:int = -0

func _ready():
	var interval = 1
	var start = 0.5
	initCallMethodTrack("effector", interval, start)
	result[0].shooter = self
#	result[0].beamLength = Globals.ROADY+10
	result[0].colors = [Color(1, 1, 1, 1), Color(1, 0, 0, 1)] 

#	weapon = Globals.getWeaponBase("Beamlance")
	
#
#	fuseColor =  weapon.colors[1].lightened(0.2)
#	{
#		"id": 0, "type": 0, "display": "Orbital Strike: Beam (A)", "weight": 3, "cost": 1, "constructor": "ITEM_BASE", "texture": "OrbitalBeam_Active", 
#		"desc": "Orbital Beams strike the combat zone.", "charges": 3, "cooldown": 5.0, "script": "OrbitalBeam_Active", "trigger": "on_use",
#		"result": [
#			{"isStat": false, "stacks": 3, "type": 4, "faction": 0, "dmgType": 0, "speed": 0, "minDmg": 7, "maxDmg": 9, "beamLength": 3000, "beamWidth": 30, "lifetime": 4.0,  "projNumber": 1, "projSize": 1.0}
#		]
#	},

func doUse():
	
	if not (player.rotation_degrees <= 90 and player.rotation_degrees >= -90):
		facing = -1
	
	x = player.global_position.x + (300 * facing)
	rota = 90 + rotashift * facing
	
#	x = 1500
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
			mods.append({"name": "Way More Lifetime", "prop": "lifetime", "effect": 1.2, "type": "pct"})
			mods.append({"name": "Beam more wide", "prop": "beamWidth", "effect": 1.2, "type": "pct"})
			mods.append({"name": "Slightly more Damage", "prop": "maxDmg", "effect": 1.2, "type": "pct"})
	
func effector():
	
	var proj = Globals.BEAM.instance()
	proj.constructProj(result[0])
	Globals.curScene.get_node("Projectiles").add_child(proj)
	proj.isStatic = true
	proj.isPiercing = true
	proj.sweeptime = proj.lifetime
	x += (Globals.rng.randi_range(150, 220) * facing)
	
	proj.rotation_degrees = rota
	proj.global_position = Vector2(x, 2)
	proj.fadeMulti = 4.0
#	proj.doBeamFadeIn()
