extends Particles2D

var remLifetime:float = 0.0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func do_init(position, rota):
	emitting = true
#	remLifetime = time
	remLifetime = lifetime
	global_position = position
	global_rotation = rota #TAU + rota#-PI/2
#	print(rota)
#	if rota < PI*0.5 and rota > -PI*0.5:
#		print("facing right")
#	else:
#		print("facing left")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	remLifetime -= delta
	if remLifetime <= 0:
#		print("queue_free")
		queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
