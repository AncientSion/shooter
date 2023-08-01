extends Capital
class_name Frigate

var display = "Frigate"

func _ready():
	$ThrusterNodes/A/Particle2D.process_material.scale = 10
	
func setStats():
	maxHealth = 85
	armor = 1
	speed = 60
	lootValue = 20
	#addHealthBar()

func getPossibleWeapons(index):
	match index:
		0:
			return Globals.getSpecificBaseWeaponByName("Light Autocannon");
		1:
			return Globals.getSpecificBaseWeaponByName("Light Autocannon");
