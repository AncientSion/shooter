extends Position2D

var isUpdating = false
var time: float
var offset = Vector2.ZERO

func _ready():
	offset = Vector2(0, 50)

func _physics_process(_delta):
	if not isUpdating or time <= 0: return
	time = max(0.0, time - _delta)
	#sprint(time)
	$CenterContainer/Label.text = str("%.1f" % time)

func init_floating_number(value, travel, duration, spread, color, crit = false):
	if color: $CenterContainer/Label.set("custom_colors/font_color", color)
	
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
	yield($Tween, "tween_all_completed")
	queue_free()

func init_lifetime_counter(initial):
	isUpdating = true
	$CenterContainer/Label.set("custom_colors/font_color", Color(0, 0, 0, 1))
	$CenterContainer/Label.text = str("%.1f" % initial)
#	$CenterContainer/Label.custom_fonts.font.size = 50
	time = initial
