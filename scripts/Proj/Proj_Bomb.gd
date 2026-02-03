extends Proj_Base
class_name Proj_Bomb

var rota = 0.5
#var type = 2
	
func _ready():
	pass
	
func _physics_process(_delta):
	if rotation_degrees > 90:
		rotation_degrees -= rota
		rotation_degrees = max(90, rotation_degrees)
	elif rotation_degrees < -90:
		rotation_degrees -= rota
		if rotation_degrees <= -180:
			rotation_degrees = 180
	else:
		rotation_degrees += rota
		rotation_degrees = min(90, rotation_degrees)
	
	accel = Vector2(1, 0).rotated(rotation) * speed
	velocity += accel * _delta
	velocity += gravity_vec * _delta
	position += velocity * _delta
	
func _on_Timer_timeout():
	explode()

func get_class():
	return "Proj_Bomb"
