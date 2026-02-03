extends Proj_Base
class_name Proj_Mine

#var rota = 0.5
#var type = 2
var timeRem:float = 6.5
var originPoint:Vector2 = Vector2.ZERO
var nextWayPoint:Vector2 = Vector2.ZERO
var steerForce = 30
var baseSpeed:int
var state:int = 0 # idle, change pos, seek

func constructProj(weapon):
	.constructProj(weapon)
	baseSpeed = speed
	$ColNodes/Seek/A.shape.radius = (speed + aoe) * 2
#	print(get_class(), " seek radius: ", $ColNodes/Seek/A.shape.radius)
	
func _ready():
	$Target.set_as_toplevel(true)
	$Origin.set_as_toplevel(true)
	$ThrusterPlume/Particle2D.emitting = true
	$Sprites/Main.set_as_toplevel(true)
	scale = Vector2.ZERO
	$Tween.interpolate_property(self, "scale",
		Vector2.ZERO, Vector2(1.0, 1.0), 0.5,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	
func _physics_process(_delta):
	
	$Sprites/Main.rotation += 1.0 * _delta
	
	if state == 0: #idle
		velocity *= 0.97
		timeRem -= _delta
		if timeRem <= 0.0:
			setNewWayPoint()
		return
		
	accel += seek()
	accel = accel.limit_length(speed*2)
	velocity += accel * _delta
	velocity = velocity.limit_length(speed)
#	velocity += gravity_vec * _delta / 10
	position += velocity * _delta
	rotation = velocity.angle()
	
	if state == 2: #seek
		nextWayPoint = target.global_position
		$Target.position = nextWayPoint
	elif state == 1: #change pos
		timeRem -= _delta
		if timeRem <= 0.0:
			timeRem = 3.0
			accel = Vector2.ZERO
			state = 0
			$ThrusterPlume/Particle2D.emitting = false

func setNewWayPoint():
#	rotation = global_rotation - PI + rand_range(-0.3, 0.3) * PI
	timeRem = 6.5
	nextWayPoint = global_position + Vector2(speed * timeRem, 0).rotated(global_rotation - PI + rand_range(-0.5, 0.5) * PI)
#	nextWayPoint = global_position + Vector2(100, 0).rotated(deg2rad(Globals.rng.randi_range(1, 360)))
	$Target.position = nextWayPoint
	state = 1
	$ThrusterPlume/Particle2D.emitting = true
	
func _on_Timer_timeout():
	explode()

func get_class():
	return "Proj_Mine"
	
func seek(): 
	var steer = Vector2.ZERO
	var desired = (nextWayPoint - position).normalized() * speed
	steer = (desired - velocity).normalized() * steerForce
	return steer

#	var vector_to_target = (nextWayPoint - global_position).normalized() * speed
#	var turn = (vector_to_target - velocity).normalized() * steerForce
#	return turn

func _draw():
	draw_arc(Vector2.ZERO, $ColNodes/Seek/A.shape.radius, 0, TAU, 24, Color(1, 0, 0, 1), 1)
#	print("draw")
	
	
func _on_Seek_area_entered(area):
#	print(area.owner.get_class(), "->", area.name, " entering ", self.get_class(), "->", name)
	if isEnemy(area.owner.faction):
		state = 2
		speed = baseSpeed * 8
		steerForce *= 2
		target = area.owner
		$ColNodes/Seek/A.shape.radius *= 3
		$ThrusterPlume/Particle2D.emitting = true
		update()

func _on_Seek_area_exited(area):
#	print(area.owner.get_class(), "->", area.name, " exiting ", self.get_class(), "->", name)
	if area.owner == target:
		state = 0
		speed = baseSpeed
		steerForce /= 2
		$ColNodes/Seek/A.shape.radius /= 3
		$ThrusterPlume/Particle2D.emitting = false
		update()
		timeRem = 6.0
	
func isEnemy(otherFaction):
	if otherFaction == -1:
		return false
	if faction == 0 and otherFaction == 1:
		return true
	elif faction == 1 and otherFaction != 1:
		return true
	return false
