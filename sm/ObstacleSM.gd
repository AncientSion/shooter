extends Node
class_name ObstacleSM

var active = true
var state = null
var prev_state = null
var states = {}

onready var parent = get_parent()

#func _physics_process(delta):
func _process_state_logic(_delta):
	pass
