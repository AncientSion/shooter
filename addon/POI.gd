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

func add_indicator(context, target):
#	var name = str(target.name, "-", target.id)
	print(target)
	var pointer = Globals.POI_MARKER.instance()
	pointer.id = target.id
	pointer.target = target
	pointer.context = context
	$actives.add_child(pointer)
	target.target_indicator = pointer
	emit_signal("indicator_added")

func remove_indicator(target):	
	for n in $actives.get_children():
		if n.id == target.id:
			n.queue_free()
			emit_signal("indicator_removed")
			return
	
#	var node = $actives.get_node(str(target.name, "-", target.id))
#	var node = $actives.get_node(target.name)
#	if node:
#		node.queue_free()
#		emit_signal("indicator_removed")

func screen_size_changed():
	for c in $actives.get_children():
		c.set_screen_size()

#func add_poi_marker(target):
#	Globals.UI.add_indicator(target, PLAYER)
#	curScene.get_node("UI/POI").add_indicator(target, PLAYER)
#
#func remove_poi_marker(target):
#	if "target_indicator" in target and target.target_indicator != null and is_instance_valid(target.target_indicator):
#		target.target_indicator.queue_free()
