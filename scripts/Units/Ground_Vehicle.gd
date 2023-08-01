extends Ground_Entity
class_name Ground_Vehicle

var behaviors = ["Patrol", "Guard", "Seek"]
var lerp_accel = 0.02

# Called when the node enters the scene tree for the first time.
func _ready():
	startPos = position
	
func _physics_process(delta):
	if activeBehavior == 1:
		velocity = lerp(velocity, Vector2.ZERO, lerp_accel)
	else: 
		velocity = lerp(velocity, direction.normalized() * self.speed, lerp_accel)
	
	#velocity = direction * self.speed
