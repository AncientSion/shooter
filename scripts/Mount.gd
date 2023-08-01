extends Base_Entity
class_name Base_Mount

export var maximum_rotation: float = 90
export var startAngle: int = 0
export var turnrate:float
#var anchor: Vector2 = Vector2.ZERO
#var current_rot: Vector2 = Vector2.ZERO

var display = "Mount"

func _ready():
	maxHealth = health
	add_to_group("isMount")

func setFriendly():
	add_to_group("hostile_turret")
	.setFriendly()
	
func setHostile():
	add_to_group("friendly_turret")
	.setHostile()

func addEffectNode(node):
	node.position = global_position - owner.global_position
	node.lifetime *= 2
	owner.get_node("EffectNodes").add_child(node)
	
func disableCollisionNodes():
	$ColNodes/DmgNormal.set("monitoring", false)
	$ColNodes/DmgNormal.set("monitorable", false)
	for n in $ColNodes/DmgNormal.get_children():
		n.disabled = true
		
func makeUntargetable():
	$Sprite.hide()
	.makeUntargetable()


func kill():
	.kill()
	$Weapon.kill()
	
	if debug_ui_node != null:
		debug_ui_node.queue_free()
	
	
#export var maximum_rotation: float = 90
#export var startAngle: int = 0
#var anchor: Vector2 = Vector2.ZERO
#var current_rot: Vector2 = Vector2.ZERO
#
#func _ready():
#	anchor = Vector2.RIGHT.rotated(deg2rad(startAngle))
#	current_rot = anchor
#	maximum_rotation = deg2rad(maximum_rotation)
