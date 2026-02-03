extends Weapon_Base
class_name Weapon_Melee

var full_duration:float = 0.7
var rem_duration:float = 0.0
var swipeWidth:int = 140
	
func doDisable():
	.doDisable()
	cooldown = rof
	set_all_cooldown_timers()

var steps:Array = [
	{	"step": 0,
		"duration": 0.5,
		"rotation": -80
	},
#	{	"step": 1,
#		"duration": 0.3,
#		"rotation": -40
#	},
	{	"step": 2,
		"duration": 0.5,
		"rotation": 0
	},
#	{	"step": 3,
#		"duration": 0.3,
#		"rotation": 40
#	},
	{	"step": 4,
		"duration": 0.5,
		"rotation": 80
	},
]


func doFire(_target):
	cooldown += lifetime
#	print("doFire")
	if burst > 1:
		if !bursting:
			#print("can burst, not yet bursting")
			bursting = burst
			burstCooldown = 0.0
		
		if bursting && burstCooldown <= 0:
			bursting -= 1
			burstCooldown = burstDelay
			#print("bursting -1")
			#print("fire")
		else: return
	
	var projs = []
	
	for n in projNumber:
		projs.append(getAttackObject(curTarget))
#
	for i in len(projs):
		setProjRotation(projNumber, i, projs[i])
		setProjPosition(projNumber, i, projs[i])
#
		Globals.curScene.get_node("Projectiles").add_child(projs[i])
		
	if burst == 1 or (burst > 1 and bursting == 0):
		setPostFireCooldown()
		
	rem_duration = full_duration
		
#	doMuzzleEffect()
#	eject_shell_casing()
	applyRecoilFromWeaponFire()
	emit_signal("hasFired")
#	hjk
#	$Sprites/Sprite.show()
#	$Sprites/Sprite.rotation_degrees = -swipeWidth/2	s
	isFiring = true
	
func getMelee():
	var melee = Globals.MACE.instance()
	melee.constructProj(self)
#	rail.rotation_degrees = global_rotation_degrees + rand_range(-deviation, deviation)
	return melee

func x_doMuzzleEffect():
	$Muzzle/AnimatedSprite.show()
	$Muzzle/AnimatedSprite.frame = 0
	$Muzzle/AnimatedSprite.play()
