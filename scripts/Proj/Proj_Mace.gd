extends Proj_Base
class_name Proj_Mace

var origin:Weapon_Base

var curStep:int = -1
var rotaOffset:int = 0

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

func init():
	pass

func constructProj(weapon):
	type = weapon.type
	faction = weapon.faction
	dmgType = weapon.dmgType
	speed = weapon.speed
	minDmg = weapon.minDmg
	maxDmg = weapon.maxDmg
	aoe = weapon.aoe
	lifetime = weapon.lifetime
	projSize = weapon.projSize
	projNumber =  weapon.projNumber
	scale = Vector2(weapon.projSize, weapon.projSize)
	impactForce = weapon.recoilForce
	
	lifetime *= rand_range(0.8, 1.2)
	lifetime = 0
	
	shooter = weapon.shooter
	origin = weapon
	
func _ready():
	initNextStep()
	global_position = origin.global_position
	global_rotation_degrees = origin.global_rotation_degrees + rotaOffset
#	$AnimationPlayer.play("Swipe")
	
func _physics_process(_delta):
	lifetime -= _delta
	if lifetime <= 0:
		initNextStep()
	global_position = origin.global_position
	global_rotation_degrees = origin.global_rotation_degrees + rotaOffset

func initNextStep():
	if curStep < steps.size()-1:
#		print(steps.size())
		curStep += 1
		lifetime = steps[curStep].duration
		rotaOffset = steps[curStep].rotation
#		print("setting offset to :", rotaOffset)
#		ddd
	else:
		queue_free()
	
func postImpacting():
	pass
	
func x_ready():
	velocity = Vector2(1, 0).rotated(rotation)
	
func x_physics_process(delta):
	position += velocity * speed * delta
	
func get_class():
	return "Proj_Mace"

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Swipe":
		queue_free()
