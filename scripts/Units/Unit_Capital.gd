extends Air_Unit
class_name Capital

var travelTime:float
var travelTimeBase:float
var lerp_accel = 0.02

var behaviors = ["Patrol", "Turnaround", "Hunt", "", "", "Crash"]

func _ready():
	sightRange = 700
	
func doInit():
	.doInit()
	#addHealthBar()
	travelTimeBase = 6.9
	travelTime = travelTimeBase
	
func _physics_process(_delta):
	pass
	
func processMovement(_delta):
	if destroyed or activeBehavior == 5: return
		
	travelTime -= _delta
	if activeBehavior == 0 or activeBehavior == 2:
		velocity = lerp(velocity, direction.normalized() * self.speed, lerp_accel)
	else:
		velocity = lerp(velocity, Vector2.ZERO, lerp_accel)
		
	position += extForces * _delta
	position += velocity * _delta

func getSpawnY(viewFrom, viewTo):
	var minY = Globals.HEIGHT / 2
	var add = Globals.HEIGHT / 4
	var y =  Globals.rng.randi_range(minY-add, minY)
	return y
	
func crashIsTriggered(remDmg):
	return (activeBehavior != 5 and health < float(maxHealth)/5 and rand_range(0, 1) < remDmg / float(health))

func getBehaviorVector():
	match activeBehavior:
		0: return patrolVector()

func patrolVector(): # moves towards target
	var vector_to_target = (curTarget.global_position - global_position).normalized() * speed
	var turn = (vector_to_target - velocity).normalized() * 1
	return turn
	
func seekVector(): # moves towards target
	var vector_to_target = (curTarget.global_position - global_position).normalized() * speed

func canWarp():
	return true
 
func setupCrashing():
	if activeBehavior == 5: return
	activeBehavior = 5
#	armor = 10
	var direction:int = 1
	if $Sprite.flip_h == true:
		direction = -1
	
	var rota = round(rand_range(15, 25)) * direction
	var speed = 70
	var time = (Globals.HEIGHT - global_position.y) / speed
	var targetX = 550 * direction
	
	$Tween.interpolate_property(self, "position",
		global_position, global_position + Vector2(targetX, Globals.HEIGHT), ceil(time),
		Tween.TRANS_QUAD, Tween.EASE_IN)
		
	$Tween.interpolate_property(self, "rotation_degrees",
		rotation_degrees, rotation_degrees + rota, ceil(time* 0.9),
		Tween.TRANS_QUAD, Tween.EASE_IN)
		
	$Tween.start()
	yield($Tween, "tween_all_completed")
