extends Capital
class_name Cargo_Hauler

var display = "Cargohauler"

func _ready():
	set_physics_process(false) 
	activeBehavior = 0
#	connect("mouse_entered", self, "_on_mouse_entered")
#	connect("mouse_exited", self, "_on_mouse_exited")
	
func _physics_process(_delta):
	velocity = direction * self.speed
	
func setStats():
	maxHealth = 90
	armor = 1
	speed = 35
	lootValue = 0
	
func getPossibleWeapons(index):
	var weapon = Globals.weapon_shield.instance()
#func construct(init_type, init_display, init_shield, init_shieldDist = 60, init_shieldLength = 36):
	weapon.construct(5, "Shield", 3)
	return weapon
	weapon.construct(1, "V Light Gun", 0.7, 1, 10, 200, 500, 1, 2, 10, 0, 8, false, 3)
	return weapon

#func _on_mouse_entered():
#	print("mouse in")
#func _on_mouse_exited():
#	print("mouse out")
