extends Position2D

var ticks = 0
var nowLifetime:float = 0.01
var maxLifetime:float
var startAoe:int
var endAoe:int

func construct(init_maxLifetime, init_startAoe, init_endAoe):
	maxLifetime = init_maxLifetime
	startAoe = init_startAoe
	endAoe = init_endAoe

func _ready():
	update()
#	pass
	
func _physics_process(delta):
#	return
	ticks += 1
	nowLifetime += delta
	if ticks == 15:
		ticks = 0
		rotation += PI/8
		#print("update")
		update()
	
func _draw():
		draw_arc(Vector2(0, 0), endAoe, 0, 2*PI, 8, Color(1, 0, 0, 0.5), 5)
#		return
#		var fract = nowLifetime / maxLifetime
#		draw_circle(Vector2(0, 0), startAoe - endAoe*fract, Color(1, 0, 0, fract))
		

#● void draw_arc(center: Vector2, radius: float, start_angle: float, end_angle: float, point_count: int, color: Color, width: float = 1.0, antialiased: bool = false)
#
#Draws a unfilled arc between the given angles. The larger the value of point_count, the smoother the curve. See also draw_circle().
#
#Note: Line drawing is not accelerated by batching if antialiased is true.
#
#Note: Due to how it works, built-in antialiasing will not look correct for translucent lines and may not work on certain platforms. As a workaround, install the Antialiased Line2D add-on then create an AntialiasedRegularPolygon2D node. That node relies on a texture with custom mipmaps to perform antialiasing. 2D batching is also still supported with those antialiased lines.
#
