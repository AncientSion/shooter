extends Node2D

var ratio:float = 0.0
var maxShield:int = 0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _draw():
#	print(Engine.get_idle_frames())
	var thick = maxShield / 7 * ratio
#	print(thick)
#	if thick % 1 != 
	draw_arc(Vector2(0, 0), 25, 0, TAU, 32, Color("00c3ff"), thick)
	update()
