extends Base_Entity
class_name Base_Mount

export var maximum_rotation: float = 90
export var startAngle: int = 0
export var turnrate:float = 0.0
export var enabled:bool = true
export var invis:bool = false

var display = "Mount"

func _ready():
	pass

func take_damage(a, b):
	.take_damage(a, b)
	
	
func do_init_mount():
	texDim = Vector2($Sprites/Main.texture.get_width() * $Sprites/Main.scale.x, $Sprites/Main.texture.get_height() * $Sprites/Main.scale.y)
	if has_node("Weapon"):
		maxHealth = health
		add_to_group("isMount")
		init_mount_debug_arcs()
		connectHurtBoxes()
		add_health_bar()
		scale_progress_bar("healthbar", 0.5)
	else:
		health = 0
		makeUntargetable()
		
	if invis:
		$Sprites/Main.hide()
	
func init_mount_debug_arcs():
	if Globals.AIMDEBUG and faction != 0 and has_node("Weapon"):
		$DebugAim.visible = true
		$DebugAim/Start.points[1] = Vector2(400, 0).rotated(deg2rad(startAngle-maximum_rotation))
		$DebugAim/End.points[1] = Vector2(400, 0).rotated(deg2rad(startAngle+maximum_rotation))

func add_smoke_fx(node):
	node.position = global_position - owner.global_position
	owner.get_node("EffectNodes").add_child(node)
	
func add_weapon(weapon):
	add_child(weapon)
	weapon.set_faction(faction)
	weapon.anchor =  Vector2.RIGHT.rotated(deg2rad(startAngle))
	weapon.current_rot = weapon.anchor
	weapon.rotation = weapon.current_rot.angle()
	weapon.maximum_rotation = deg2rad(maximum_rotation)
	weapon.turnrate = deg2rad(turnrate)
	weapon.owner_mount = self
	if turnrate == 0 or maximum_rotation == 0:
		weapon.canRotate = false

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
	disable_col_nodes()
	if has_node("Weapon"):
		$Weapon.kill()
	
	if debug_menu_row != null:
		debug_menu_row.queue_free()
	
	hide_control_nodes()
	create_final_kill_explos()

func create_final_kill_explos():
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
#	scale_progress_bar("healthbar", 0.5)
#	healthbar.get_child(0).percent_visible = false

func set_friendly():
	faction = 0
	if has_node("ColNodes"):
		for i in $ColNodes.get_children():
			i.set_collision_layer_bit(0, true)
			i.set_collision_mask_bit(3, true) #contact with enemy projs
	
func set_hostile():
	faction = 1
	if has_node("ColNodes"):
		for i in $ColNodes.get_children():
			i.set_collision_layer_bit(1, true)
			i.set_collision_mask_bit(2, true) #contact with player projs
			
func has_active_omni_shield():
	return owner.has_active_omni_shield()
#	if $Mounts.get_children():
#		if $Mounts/A.get_child(0) is Weapon_Shield_Omni:
#			if $Mounts/A.get_child(0).shield > 0:
#				return true#
#	return false
