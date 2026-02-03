extends Proj_Base
class_name Proj_Missile

var steerForce:int
var homing:bool = false
var homeTimer: float
var displaceTimer:float = 0.0
var displaceForce:float = 0.0
var displaceTimerBase:float = 0.0
var displaceForceBase:float = 0.0
var accelLimit:float
#var type:int = 2
var offset:Vector2 = Vector2.ZERO
var amplitude:float
var frequency:float

func _ready():
	pass
	
func constructProj(weapon):
	.constructProj(weapon)
		
	displaceTimerBase = weapon.displaceTimer
	displaceForceBase = weapon.displaceForce
	
	speed = round(speed) * rand_range(0.9, 1.1)
	steerForce = round(weapon.steerForce) * rand_range(0.9, 1.1)
	impactForce = weapon.recoilForce * 1
	accelLimit = speed
	displaceTimer = displaceTimerBase
	
#	offset = Globals.rng.randi_range(-25, 25)
	amplitude = 2.0
	frequency = 0.4 + rand_range(-0.1, 0.1)
	speed = 0
#	var speeeed = 350.0

func setHomingTarget(homingTarget):
	homing = true
	target = homingTarget
	rotation += rand_range(-0.1, 0.1)

func _physics_process(delta):
	missile_move_logic(delta)
#	last_missile_move_logic(delta)
	
func missile_move_logixxc(delta):

	# Calculate horizontal and vertical components based on the angle
	var horizontal_component := cos(rotation)
	var vertical_component := sin(rotation)

	speed = lerp(speed, accelLimit, 0.03)
	
	position -= offset

	offset.y = amplitude * sin(frequency * offset.x) * vertical_component
	offset.x += speed * horizontal_component * delta
#    y = amplitude * sin(frequency * x) * vertical_component
#    x += speed * horizontal_component * delta
	
	position += offset
	
	
func last_missile_move_logic(delta):
#	var amplitude = 3.0
#	var frequency = 0.6 
#	var speeeed = 350.0

	speed = lerp(speed, accelLimit, 0.02)
	
	var movement_vector = Vector2(cos(rotation), sin(rotation)) * speed * delta
	position += movement_vector
	position.y += amplitude / accelLimit * speed * sin(position.x * frequency * 2 * PI / 360)# + offset
	
func missile_move_logic(delta):
	accel += seek()
	accel = accel.limit_length(accelLimit)
	velocity += accel * delta
	velocity = velocity.limit_length(accelLimit)
#	print("missile #", get_instance_id(), " rotation_degrees: ", rotation_degrees)
	rotation = velocity.angle()
#	print("missile #", get_instance_id(), " rotation_degrees: ", rotation_degrees)
	position += velocity * delta
	
	if homeTimer > 0.0:
		homeTimer -= delta
		if homeTimer < 0.0:
			homing = true
			accelLimit *= 2
			
	if displaceTimer > 0.0:
		displaceTimer -= delta
		if displaceTimer <= 0.0:
			displaceForce = rand_range(displaceForceBase, displaceForceBase*2) * Globals.getRandomEntry([1, -1])
			displaceTimer = displaceTimerBase
			
func seek(): 
	var steer = Vector2.ZERO
	
	if homing:
		if  not is_instance_valid(target) or target == null or target.destroyed:
			#print("target invalid, null or destroyed")
			return steer
		var desired = (target.position - position).normalized() * accelLimit
		steer = (desired - velocity).normalized() * steerForce
		return steer
#	else: return Vector2(1, 0).rotated(rotation + rand_range(-0.5, 0.5)) * speed
	else: return Vector2(1, 0).rotated(rotation + displaceForce) * accelLimit

func get_class():
	return "Proj_Missile"
