extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var real = false
onready var id = Globals.getId()

# Called when the node enters the scene tree for the first time.
func _ready():
	#print("adding dummy")
	pass # Replace with function body.



func _on_Timer_timeout():
	#print("deleting dummy")
	queue_free()
	
	pass # Replace with function body.
