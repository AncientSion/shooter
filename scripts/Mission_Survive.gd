extends Area2D

var type = "Survive"
var amount = 0
var remaining = 0
var targets = []

func get_class():
	return str("MISSION", type)
