extends Node2D
#
#var remLifeTime:float = 0.0
var delay:float = 0.0

func construct():
	pass

func _physics_process(delta):
	if not visible and delay >= 0:
		delay -= delta
		if delay < 0:
			visible = true
		else:
			return
		
#	remLifeTime -= delta
#	if remLifeTime <= 0:
#		queue_free()

func _ready():
	if delay > 0:
		visible = false
