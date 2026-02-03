# POI class: Points Of Interest Node2D handling TargetIndicators
#
# This class is intended to be put into a godot CanvasLayer and is intended to hold
# and manage target indicators. It provides functions to add and remove 
extends Node2D
class_name POI

signal indicator_added
signal indicator_removed

export(bool) var propagate_screen_change = true


func _ready():
	position = OS.window_size / 2
	if propagate_screen_change:
		get_node("/root").get_viewport().connect("size_changed", self, "screen_size_changed")

func add_indicator(target, origin):
	var pointer = Globals.MARKER.instance()
	pointer.name = target.name
	pointer.target = target
	pointer.origin = origin
	$actives.add_child(pointer)
	target.target_indicator = pointer
	emit_signal("indicator_added")

func remove_indicator(target):
	var node = $actives.get_node(target.name)
	if node:
		node.queue_free()
		emit_signal("indicator_removed")

func screen_size_changed():
	for c in $actives.get_children():
		c.set_screen_size()
