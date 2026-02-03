extends Position2D

var time:float = 0.0

func _ready():
	$ColorRect.get_node("AnimationPlayer").play("shockwave")
	print("adding shockwave")

func _process(delta):
	time += delta

func _on_AnimationPlayer_animation_finished(anim_name):
	print("removing shockwave, lifetime: ", time)
	queue_free()
