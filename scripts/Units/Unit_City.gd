extends Ground_Entity
class_name City

var	display = "City"
var behaviors = ["Guard"]

func _ready():
	faction = 0
	add_to_group("skyscraper")
	modify()
	
func _physics_process(delta):
	pass
	
func setStats():
	pass

func getSpawnY(viewFrom, viewTo):
	return Globals.ROADY + Globals.rng.randi_range(-10, 10) - self.texDim.y/2

func getPossibleWeapons(index):
#func construct(init_type, init_display, init_shield, init_shieldDist = 60, init_shieldLength = 36):
	match index:
		0:
			var weapon = Globals.weapon_shield.instance()
			weapon.construct(5, "Shield", 15, 140, 85)
			return weapon
		1:
			var weapon = Globals.weapon_shield.instance()
			weapon.construct(5, "Shield", 15, 165, 85)
			return weapon
		2:
			var weapon = Globals.weapon_shield.instance()
			weapon.construct(5, "Shield", 15, 140, 85)
			return weapon

func modify():
	return
	var offset = Globals.rng.randi_range(0, floor(texDim.y*0.8))
	var spriteClone = $Sprite.duplicate()
	spriteClone.name = "SpriteExtension"
	if Globals.rng.randi_range(1, 2) % 2 != 0:
		spriteClone.flip_h = true
	spriteClone.position = Vector2(0, -offset)
	add_child(spriteClone)
		
	var totalHeight = -spriteClone.position.y + texDim.y
	
	var colShape = CollisionShape2D.new()
	colShape.shape = RectangleShape2D.new()
	$ColNodes/DmgNormal.add_child(colShape)
	
	var extents = floor(totalHeight/2)
	colShape.shape.extents = Vector2(18, extents-2)
	colShape.position.y = -floor(offset/2)
	
	maxHealth = totalHeight
	health = totalHeight
