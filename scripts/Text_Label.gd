extends Control

var isUpdating = false
var time: float
var offset = Vector2.ZERO

func _ready():
	offset = Vector2(0, 50)

func _physics_process(_delta):
	if isUpdating:
		time = max(0.0, time - _delta)
		#sprint(time)
		$CenterContainer/Label.text = str("%.1f" % time)
	if time < 0.0:
		queue_free()

func init_text_label_string(initial):
#	$CenterContainer/Label.set("custom_colors/font_color", Color(0, 0, 0, 1))
	$CenterContainer/Label.text = str("%.1f" % initial)
#	$CenterContainer/Label.custom_fonts.font.size = 50
	time = initial

func update_label(value):
	$CenterContainer/Label.text = str("%.1f" % value)
