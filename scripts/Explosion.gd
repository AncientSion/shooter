extends Position2D

func _ready():
	rotation = Globals.rng.randi_range(0, 2*PI)
	pass

func _physics_process(delta):
	pass


func _on_AnimatedSprite_animation_finished():
	#print("delete")
	queue_free()
