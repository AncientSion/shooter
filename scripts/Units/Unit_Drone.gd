extends Air_Unit
class_name Drone_a

var display = "Drone"

var behaviors = ["Seek", "Guard", "Evade", "3", "4", "Crash"]

var escortTarget:Base_Entity
#var currentMoveTarget = Vector2.ZERO
var targetDim

var changePosTimer:float


func _ready():
	$Mounts/A/Sprite.visible = false
	$TimerNodes/BehaveTimer.stop()

func doInit():
	.doInit()
	activeBehavior = 0
	changePosTimer = 1.0
	
func setStats():
	maxHealth = 35
	armor = 1
	speed = 185
#	maxSpeed = 500
	lootValue = 6

func _physics_process(_delta):
	pass
		
func processMovement(_delta):
	if destroyed or moveTarget == null: return
	changePosTimer -= _delta
	
	if changePosTimer <= 0:
		changePosTimer = 3.0
		activeBehavior = 0
		setNewMoveTarget()
#		global_position = moveTarget

	update()
#	print(moveTarget)
	if global_position.distance_to(moveTarget) <= 5:
		activeBehavior = 1

#	accel += Vector2.ZERO#getBehaviorVector()
	accel += getBehaviorVector()
	accel = accel.limit_length(maxSpeed)
	velocity += accel * _delta
	velocity = velocity.limit_length(maxSpeed)
	
	position += extForces * _delta
	position += velocity * _delta
	
	if activeBehavior == 5: return
	if target == null:
		if moveTarget.x - position.x < 0:
			if $Sprite.flip_h == false:
				doTurnaround()
		else:
			if $Sprite.flip_h == true:
				doTurnaround()
	else: doFaceTarget()
	
func _draw():
#	print("draw")
#	print(moveTarget)
#	draw_rect(Rect2(escortTarget.global_position.x - escortTarget.texDim.x / 2 - global_position.x, escortTarget.global_position.y - escortTarget.texDim.y / 2 - global_position.y, escortTarget.texDim.x, escortTarget.texDim.y), Color(1, 1, 1, 1))
	draw_circle(moveTarget - global_position, 15, Color(1, 0, 0))
	
func setNewMoveTarget():
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
	if target.global_position.x - position.x < 0:
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
	return
#	var weapon = Globals.getSpecificBaseWeaponByName("Beamlance");
#	var weapon = Globals.getSpecificBaseWeaponByName("Heavy Machinecannon");
	var weapon = Globals.getSpecificBaseWeaponByName("Light Railgun");
#	weapon.makeUntargetable()
	return weapon

func setEscortTarget(t):
	escortTarget = t

func getBehaviorVector():
	match activeBehavior:
		0: return seekVector()
		1: return standoffVector()
		2: return evadeVector()
#		5: return crashVector()

func seekVector():
	var vector_to_target = (moveTarget - global_position).normalized() * speed
	return vector_to_target

func standoffVector():
	return Vector2.ZERO
	var vector_to_target = (moveTarget - global_position).normalized() * speed / 100
	return vector_to_target

func evadeVector():
	var vector_from_target = (global_position - moveTarget).normalized() * speed
	return vector_from_target
