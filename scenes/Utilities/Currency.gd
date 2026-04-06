extends Base_Entity
class_name Currency

var moveTarget = Vector2.ZERO
var velocity = Vector2.ZERO
var accel = Vector2.ZERO
var steer_force = 30
var resValue:int

func _ready():
	pass 
	
func _physics_process(delta):
	accel += seekVector()
	accel = accel.limit_length(maxSpeed/20)
	velocity += accel
	velocity = velocity.limit_length(maxSpeed)
	position += velocity * delta
	
func connectHurtBoxes():
	return
	
func setStats():
	maxHealth = 1
	maxSpeed = 500

func seekVector(): # moves towards target
	var vector_to_target = (curTarget.global_position - global_position).normalized() * maxSpeed
	var turn = (vector_to_target - velocity).normalized() * steer_force
	#print(turn)
	return turn

func _on_ColNodes_area_entered(area):
	if not area.owner.isPlayer: return
	area.owner.add_resources(resValue)
	queue_free()
