extends Position2D

var offset = Vector2.ZERO

func _ready():
	offset = Vector2(0, 50)

func _physics_process(_delta):
	pass

func init_floating_number(value, travel, duration, spread, crit, color):
	if color:
		$CenterContainer/Label.set("custom_colors/font_color", color)
	
	$CenterContainer/Label.text = str(value)
	var movement = travel.rotated(rand_range(-spread/2, spread/2))
	#rect_pivot_offset = rect_size / 2

	$Tween.interpolate_property(self, "global_position",
			position, position + movement,
			duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(self, "modulate:a",
			1.0, 0.0, duration,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			
	if crit:
		modulate = Color(1, 0, 0)
		$Tween.interpolate_property(self, "scale",
			scale*2, scale,
			0.4, Tween.TRANS_BACK, Tween.EASE_IN)

	$Tween.start()
#	$Tween.connect("tween_all_completed", self, "queue_free")
	get_tree().create_timer(duration).connect("timeout", self, "queue_free")
#	queue_free()
