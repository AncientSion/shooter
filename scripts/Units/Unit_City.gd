extends Ground_Entity
class_name City

var	display = "City"

func _ready():
	faction = 0
	add_to_group("skyscraper")
	modify()

func setStats():
	.setStats()
	coreRange = 150

func getSpawnY(viewFrom, viewTo):
	return Globals.ROADY + Globals.rng.randi_range(-10, 10) - self.texDim.y/2

func getPossibleWeapons(index):
#	var stats = {"maxShield": 60, "shieldRegenTime": 0.5, "shieldBreakTime": 6.0, "shieldFastCharge": 0.75, "shieldDist": 80, "shieldLength": 50}
#	shield.construct(5, "Shield", stats)
#	shield.add_shield_bar()
#	shield.scaleBar("shieldbar", 0.5)
#	
	var	shield = Globals.weapon_shield_dir.instance()
	var stats = {}
	match index:
		0:
			stats = {"maxShield": 120, "shieldRegenTime": 0.5, "shieldBreakTime": 18.0, "shieldFastCharge": 0.25, "shieldDist": 110, "shieldLength": 90}
#			stats = {"maxShield": 180, "shieldRegenTime": 0.5, "shieldBreakTime": 24.0, "shieldFastCharge": 0.25, "shieldDist": 150, "shieldLength": 200}
#			var weapon = Globals.weapon_shield_dir.instance()
#			weapon.construct(5, "Shield", 50, 140, 85)
#			return weapon
		1:
			stats = {"maxShield": 120, "shieldRegenTime": 0.5, "shieldBreakTime": 18.0, "shieldFastCharge": 0.25, "shieldDist": 135, "shieldLength": 90}
#			var weapon = Globals.weapon_shield_dir.instance()
#			weapon.construct(5, "Shield", 50, 165, 85)
#			return weapon
		2:
			stats = {"maxShield": 120, "shieldRegenTime": 0.5, "shieldBreakTime": 18.0, "shieldFastCharge": 0.25, "shieldDist": 110, "shieldLength": 90}
#			var weapon = Globals.weapon_shield_dir.instance()
#			weapon.construct(5, "Shield", 50, 140, 85)
#			return weapon
			
	shield.construct(5, "Shield", stats)
	shield.shield = shield.maxShield
	shield.add_shield_bar()
	shield.scaleBar("shieldbar", 0.8)
	return shield
#	pass

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
