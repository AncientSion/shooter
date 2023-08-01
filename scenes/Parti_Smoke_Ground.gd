extends Particles2D

func _ready():
	one_shot = true
	emitting = true
	var time = (lifetime * 2) / speed_scale
	get_tree().create_timer(time).connect("timeout", self, "queue_free")
