extends Viewport

var scale_factor = 1.0
	
func adjust_ui_resolution():
	return
	scale_factor = 1920 / Globals.SCREEN.x
	size *= scale_factor
#	scale_label.text = "Scale: %s%%" % str(scale_factor * 100)
