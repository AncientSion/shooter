extends Area2D

var type = "Hold Area"
var x
var y
var w
var h
var color = Color(1.0, 0.0, 0.0, 0.2)
var inArea = false
var amount = 0
var remaining = 0

func _ready():
	pass
	
func process():
	set_physics_process(true)
	#update()

func get_class():
	return str("MISSION", type)

func doInit(init_x, init_y, init_w, init_h):
#	print(init_x, "/", init_y)
	position = Vector2(init_x + init_w/2, init_y + init_h/2)
	x = init_x
	y = init_y
	w = init_w
	h = init_h
	#var col = $CollisionShape2D
	
	#print(col.shape.extents)
	#print(col.position)
	
	$CollisionShape2D.shape.extents = Vector2(w/2, h/2)
	
func _draw():
	draw_rect(Rect2(0-(w/2), 0-(h/2), w, h), Color(1, 0, 0, 0.2))

func _on_Enemy_Ground_Vehicle_destroyed():
	print("_on_Enemy_Ground_Vehicle_destroyed")

func _on_Area2D_area_entered(area):
	inArea = true
	
func _on_Area2D_area_exited(area):
	inArea = false
