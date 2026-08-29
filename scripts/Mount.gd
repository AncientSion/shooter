extends Base_Entity
class_name Base_Mount

export var maximum_rotation: float = 89
export var turnrate:float = 1.0
export var enabled:bool = true
export var invis:bool = false

var weapon = null

var init_turret_angle: int = -90
var arc_midpoint_v: Vector2
var max_rota_radian:float
var canRotate:bool = true

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
		add_health_bar(0.5)
		scale_progress_bar("healthbar", 0.5)
	else:
		health = 0
		makeUntargetable()
		
	if invis:
		$Sprites/Main.hide()
	
func init_mount_debug_arcs():
	if Globals.AIMDEBUG and faction != 0 and has_node("Weapon"):
		$DebugAim.visible = true
		$DebugAim/Start.points[1] = Vector2(400, 0).rotated(deg2rad(init_turret_angle-maximum_rotation))
		$DebugAim/End.points[1] = Vector2(400, 0).rotated(deg2rad(init_turret_angle+maximum_rotation))

func add_smoke_fx(node):
	node.position = global_position - owner.global_position
	owner.get_node("EffectNodes").add_child(node)

func add_weapon(wpn):
	add_child(wpn)
	wpn.set_faction(faction)
	weapon = wpn
	set_mount_firing_arc()

func set_mount_firing_arc():
	arc_midpoint_v = Vector2.RIGHT.rotated(deg2rad(init_turret_angle))
	weapon.current_rot_v = arc_midpoint_v
	weapon.rotation_degrees = init_turret_angle
	max_rota_radian = deg2rad(maximum_rotation)
	turnrate = deg2rad(turnrate)
	
	if turnrate == 0 or maximum_rotation == 0:
		canRotate = false

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
	if maxHealth > 0:
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

func add_health_bar(size:float = 1.0):
	if health <= 0:
		return
		
	.add_health_bar(size)
	
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
func mount_has_valid_target():
#	print("wpn_has_valid_target on ", display, " #", id)
	if not is_instance_valid(curTarget) or curTarget.destroyed == true or curTarget.ready == false: return false
	if forcedLock and curTarget != null:
		return !curTarget.destroyed
	if not weapon.is_in_range(curTarget.global_position):
		#print(display, " to ", target.display, " dist > speed x2 = illegal target")
		return false
	if not is_in_arc(global_position.direction_to(curTarget.global_position)): 
		return false
	return true
	
func handle_mounted_weapon(targetsArr):
	if !is_instance_valid(weapon) or weapon.destroyed or !weapon.active:
		return
	if !mount_has_valid_target(): # does it NOT have a target ?
		set_target_for_mount(targetsArr) # if so, assign a valid target to this weapon
	if curTarget == null: # if it still has no target, next
		return
	do_track_target()
	if weapon.can_fire(): # check cooldown, emp or other conditions
		if weapon.bursting or weapon.has_fire_solution(curTarget): # do i have the right vector / rotation achieved `?
			weapon.handle_firing(curTarget) # spawn projectile
			
func set_target_for_mount(allTargets):
	if allTargets.empty():
		return
	var bestPrio:int = 10
	var bestTarget = null
	var targets = Array()
	for n in allTargets:
		if not n.target.isLegalTarget():
			continue
		if not weapon.is_in_range(n.target.global_position):
			continue
		var vec = global_position.direction_to(n.target.global_position)
#		print(rad2deg(vec.angle()))
		if not is_in_arc(vec):
			continue
			
		if n.prio < bestPrio:
			bestPrio = n.prio
			bestTarget = n.target
	
	if bestTarget != null:
		curTarget = bestTarget
	else:
		curTarget = null 
	return
	
func is_in_arc(vec):
	if max_rota_radian == PI: return true
	var from = arc_midpoint_v.rotated(-max_rota_radian + global_rotation)
	var to = arc_midpoint_v.rotated(max_rota_radian + global_rotation)
	if ((from.y * vec.x - from.x * vec.y) * (from.y * to.x - from.x * to.y) >= 0 && (to.y * vec.x - to.x * vec.y) * (to.y * from.x - to.x * from.y) >= 0):
		return true
	return false

func do_track_target():
	if not canRotate: return
	if not is_instance_valid(curTarget): return

	# Get direction to target in local space
	var target_dir = (curTarget.global_position - global_position).normalized()
	var target_angle = target_dir.angle()

	# Calculate shortest rotation needed
	var change = wrapf(target_angle - weapon.global_rotation, -PI, PI)

	# Apply turnrate limit
	change = clamp(change, -turnrate, turnrate)

	# Calculate candidate rotation
	var candidate = weapon.current_rot_v.rotated(change)

	# Check if within rotation limits
	var angle_from_arc_midpoint_v = wrapf(arc_midpoint_v.angle_to(candidate), -PI, PI)

	if abs(angle_from_arc_midpoint_v) <= max_rota_radian:
		# Within limits - apply full rotation
		weapon.current_rot_v = candidate
		weapon.rotation = weapon.current_rot_v.angle()
	else:
		# Clamp to nearest rotation limit
		var clamped_angle = clamp(angle_from_arc_midpoint_v, -max_rota_radian, max_rota_radian)
		weapon.current_rot_v = arc_midpoint_v.rotated(clamped_angle)
		weapon.rotation = weapon.current_rot_v.angle()
