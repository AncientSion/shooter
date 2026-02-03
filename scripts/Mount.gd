extends Base_Entity
class_name Base_Mount

export var maximum_rotation: float = 90
export var startAngle: int = 0
export var turnrate:float
export var enabled:bool = true
export var invis:bool = false

func takeDamage(a, b):
	.takeDamage(a, b)

var display = "Mount"

func _ready():
	pass
#	doInit()
	
func do_init():
#	print("mount init")
	maxSmoke = 1
	maxHealth = health
	add_to_group("isMount")
	initArc()
	if health == 0:
		makeUntargetable()
	if invis:
		$Sprites/Main.hide()
	
func initArc():
	if Globals.AIMDEBUG and faction != 0:
		$DebugAim.visible = true
		$DebugAim/Start.points[1] = Vector2(400, 0).rotated(deg2rad(startAngle-maximum_rotation))
		$DebugAim/End.points[1] = Vector2(400, 0).rotated(deg2rad(startAngle+maximum_rotation))

func setFriendly():
	.setFriendly()
	
func setHostile():
	.setHostile()

func add_smoke_fx(node):
	node.position = global_position - owner.global_position
	owner.get_node("EffectNodes").add_child(node)

func getRamDamage():
	var ramBullet = Globals.BULLET.instance()
	Globals.curScene.get_node("Refs").add_child(ramBullet)
	ramBullet.minDmg = 2
	ramBullet.maxDmg = 3
	var effect = (ramBullet.minDmg + ramBullet.maxDmg) * 10 * mass * 2
	ramBullet.impactForce = -Vector2(round(pow(effect, 0.6)), 0)
	return ramBullet
	
func kill():
	destroyed = true
	set_physics_process(false)
	disableCollisionNodes()
	if has_node("Weapon"):
		$Weapon.kill()
	
	if debug_menu_row != null:
		debug_menu_row.queue_free()
		
	for n in $ControlNodes.get_children():
		n.hide()

	handle_kill_explos()

func handle_kill_explos():
	var amount = 1
	for n in amount:
		var explo = Globals.getExplo("wreck", get_dmg_gfx_scale())
		var pos = get_point_inside_tex()
		explo.position = global_position + pos
		Globals.curScene.get_node("Various").add_child(explo)
	
func get_dmg_gfx_scale():
	return 0.7

func initRamming(area):
	return

func add_health_bar():
	.add_health_bar()
	
	healthbar.offset.y = sign(position.y) * 60
#	print(position)
#	print(global_position)
#
#	scaleBar("healthbar", 0.5)
#	healthbar.get_child(0).percent_visible = false
