extends Proj_Base
class_name Proj_Rail

#var type = 6

func init():
	pass
	
func _ready():
	velocity = Vector2(1, 0).rotated(rotation) * speed

func _physics_process(_delta):
	velocity *= 0.999
	velocity += gravity_vec * _delta / 4
	rotation = velocity.angle()
	position += velocity * _delta

func on_lifetime_timeout():
	return

func get_class():
	return "Proj_Rail"
