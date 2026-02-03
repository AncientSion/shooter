extends Position2D

func _ready():
	rotation = Globals.rng.randi_range(0, 2*PI)


func _physics_process(_delta):
	pass

func _on_AnimatedSprite_animation_finished():
	#print("delete")
	queue_free()
