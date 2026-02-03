# TargetIndicator class: Show the direction of an offscreen target
#
# This class shows the direction of its target while it is offscreen by sticking to the
# edge of the screen and rotating in the direction of its target.
# This class expect its target to have a VisibilityNotifier2D node in order to detect if
# it is on screen or not.
# 
# Its property "origin" should be a node that is always at the center of the screen.
extends Node2D
class_name Target_Indicator
export(String) var visibility_notifier = "VisibilityNotifier2D"

var target
var origin
var h_screen_size


func _ready():
	set_screen_size()
#	disable()

func _process(_delta):
	if target.get_node(visibility_notifier).is_on_screen():
		hide()
	elif visible:
		calcPosition()
	elif not visible:  
		show()
#		var indicator_pos = target.global_position - origin.global_position  
#		rotation = indicator_pos.normalized().angle()
#
#		if h_screen_size != Vector2.ZERO:
#			var ratio_x = abs(indicator_pos.x / h_screen_size.x) * 1.05
#			var ratio_y = abs(indicator_pos.y / h_screen_size.y) * 1.05
#			indicator_pos /= ratio_x if ratio_x > ratio_y else ratio_y
#			position = indicator_pos

func set_screen_size():
	h_screen_size = (OS.window_size / 2)
#	set_process(true)

func disable():
	hide()
	set_process(false)
	
func enable():
	show()
	set_process(true)
	calcPosition()
	
func calcPosition():
	var indicator_pos = target.global_position - origin.global_position  
	rotation = indicator_pos.normalized().angle()
	
	if h_screen_size != Vector2.ZERO:
		var ratio_x = abs(indicator_pos.x / h_screen_size.x) * 1.05
		var ratio_y = abs(indicator_pos.y / h_screen_size.y) * 1.05
		indicator_pos /= ratio_x if ratio_x > ratio_y else ratio_y
		position = indicator_pos
