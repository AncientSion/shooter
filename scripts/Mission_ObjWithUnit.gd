extends Node

var type = ""
var amount = 0
var remaining = 0
var targets = Array()

func _ready():
	remaining = amount

func get_class():
	return str("MISSION", type)
