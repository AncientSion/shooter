extends Air_Unit
class_name Drone

var display = "Drone"

var behaviors = ["Seek", "Orbit", "Evade", "Hover", "4", "Crash"]

var escortTarget:Base_Entity
var patrolPointIndex:int = -1
var changePosTimer:float
var hoverFrames:int = 0
var hoverDir:int = 1
func _ready():
	$Mounts/A/Sprite.visible = false
	$TimerNodes/BehaveTimer.stop()

func doInit():
	.doInit()
	activeBehavior = 0
	changePosTimer = 10.0
	
	patrolPointIndex = Globals.rng.randi_range(0, escortTarget.get_node("PatrolNodes").get_child_count()-1)
	moveTarget = escortTarget.get_node("PatrolNodes").get_child(patrolPointIndex).global_position
	
	return
	
	var patrolPoints = escortTarget.get_node("PatrolNodes").get_children()
	moveTarget = Globals.getRandomEntry(patrolPoints).global_position
	for n in patrolPoints:
		patrolPointIndex += 1
		if n.global_position == moveTarget:
#			print("setting to point ", n)
			break
		
func setStats():
	maxHealth = 35
	armor = 1
	speed = 150
	thrust = 350
#	maxSpeed = 500
	lootValue = 6

func _physics_process(_delta):
	pass
		
func processMovement(_delta):
	if destroyed or moveTarget == null: return
	changePosTimer -= _delta
	
	if changePosTimer <= 0:
		changePosTimer = 10.0
		activeBehavior = 0
		maxSpeed = speed
		setNewMoveTarget()
	elif activeBehavior != 3 and global_position.distance_to(moveTarget) < 50:
#		print("arriving!")
		activeBehavior = 3
#		maxSpeed /= 4
	elif activeBehavior == 3:
		maxSpeed = max(round(speed/3), lerp(maxSpeed, 0, 0.01))
#		print(maxSpeed)
		hoverFrames += 1
		if hoverFrames > 120:
			hoverDir *= -1
			hoverFrames = 0
			moveTarget += Vector2(hoverDir * 50, Globals.rng.randi_range(-6, 6))
	update()

	accel += getBehaviorVector()
	accel = accel.limit_length(thrust)
	velocity += accel * _delta
	velocity = velocity.limit_length(maxSpeed)
	
	position += extForces * _delta
	position += velocity * _delta
	
	if activeBehavior == 5: return
	if curTarget == null:
		if moveTarget.x - position.x < 0:
			if $Sprite.flip_h == false:
				doTurnaround()
		else:
			if $Sprite.flip_h == true:
				doTurnaround()
	else: doFaceTarget()
	
	
#	if not arriving and global_position.distance_to(moveTarget) <= 100:
#		print("slowing down")
#		arriving = true
#		activeBehavior = 2
#	if arriving and activeBehavior == 2 and global_position.distance_to(moveTarget) <= 30:
#		print("setting to orbit")
#		activeBehavior = 1
#
func _draw():
#	print("draw")
#	print(moveTarget)
#	draw_rect(Rect2(escortTarget.global_position.x - escortTarget.texDim.x / 2 - global_position.x, escortTarget.global_position.y - escortTarget.texDim.y / 2 - global_position.y, escortTarget.texDim.x, escortTarget.texDim.y), Color(1, 1, 1, 1))
	draw_circle(moveTarget - global_position, 10, Color(1, 0, 0))
	
func setNewMoveTarget():
	patrolPointIndex = Globals.rng.randi_range(0, escortTarget.get_node("PatrolNodes").get_child_count()-1)
	var vari = 25
	moveTarget = escortTarget.get_node("PatrolNodes").get_child(patrolPointIndex).global_position + Vector2(Globals.rng.randi_range(-vari, vari), Globals.rng.randi_range(-vari, vari))
	return
	
	patrolPointIndex += 1
	if patrolPointIndex == escortTarget.get_node("PatrolNodes").get_children().size():
		patrolPointIndex = 0
	moveTarget = escortTarget.get_node("PatrolNodes").get_child(patrolPointIndex).global_position + Vector2(Globals.rng.randi_range(-vari, vari), Globals.rng.randi_range(-vari, vari))
	
func setNewMoveTargetRng():
	# Calculate the range for the offset
	var offset_range = 150

	# Generate random offsets until the resulting point is outside the rectangle
	moveTarget = escortTarget.global_position
	
	while is_point_inside_rectangle(moveTarget, escortTarget.global_position.x, escortTarget.global_position.y, escortTarget.texDim.x, escortTarget.texDim.y):
		# Generate random offsets within the range
		var offset_x = rand_range(-escortTarget.texDim.x / 2 - offset_range, escortTarget.texDim.x / 2 + offset_range)
		var offset_y = rand_range(-escortTarget.texDim.y / 2 - offset_range, escortTarget.texDim.y / 2 + offset_range)

		# Calculate the point outside the rectangle
		moveTarget = Vector2(escortTarget.global_position.x + offset_x,  escortTarget.global_position.y + offset_y)
		
	update()


func is_point_inside_rectangle(point, rectangle_center_x, rectangle_center_y, rectangle_width, rectangle_height):
	var min_x = rectangle_center_x - rectangle_width / 2
	var max_x = rectangle_center_x + rectangle_width / 2
	var min_y = rectangle_center_y - rectangle_height / 2
	var max_y = rectangle_center_y + rectangle_height / 2
	return point.x >= min_x and point.x <= max_x and point.y >= min_y and point.y <= max_y
		
func doFaceTarget():
	if curTarget.global_position.x - position.x < 0:
		if $Sprite.flip_h == false:
			doTurnaround()
	else:
		if $Sprite.flip_h == true:
			doTurnaround()

func doTurnaround():
	$Sprite.flip_h = !$Sprite.flip_h
	mirrorTurrets()
	mirrorThrusters()
	mirrorVarious()
	mirrorColNodes()
	mirrorSprite()

func mirrorSprite():
	if $Sprite.flip_h == true:
		$Sprite.rotation = -(2*rotation)
	else: $Sprite.rotation = 0

func getPossibleWeapons(index):
#	return
#	var weapon = Globals.getSpecificBaseWeaponByName("Beamlance");
	var weapon = Globals.getSpecificBaseWeaponByName("Light Machinecannon");
#	var weapon = Globals.getSpecificBaseWeaponByName("Light Railgun");
#	weapon.makeUntargetable()
	return weapon

func setEscortTarget(t):
	escortTarget = t

func getBehaviorVector():
	match activeBehavior:
		0: return seekVector()
		1: return orbitVector()
		2: return evadeVector()
		3: return seekVector()
		
#		5: return crashVector()

func seekVector():
#	var vector_to_target = (moveTarget - global_position).normalized() * thrust
	var vector_to_target = (moveTarget - global_position)
	var dist = vector_to_target.length()
	var slowingDist = 400
	
	if dist < slowingDist:
		vector_to_target = vector_to_target.normalized() * thrust * (dist / slowingDist)
#		print("a__",vector_to_target)
	else:
		vector_to_target = vector_to_target.normalized() * thrust
#		print("b__",vector_to_target)
	return vector_to_target
	
func evadeVector():
	return seekVector()
	var vector_from_target = (global_position - moveTarget).normalized() * speed
	return vector_from_target

func orbitVector():
	#print(target.global_position)
	var desired_direction:Vector2 = global_position.direction_to(moveTarget) * speed
	return desired_direction
