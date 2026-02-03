extends Node
class_name SM

var active = true
var enabled = true
var canChangeState = true
var state = null
var prev_state = null
var states = {}

onready var parent = get_parent()

#func _physics_process(delta):
func _process_state_logic(delta):
	if state != null and enabled:
		if state != states.wander:
			if parent.hasNoTargetSet():
				parent.remove_cur_target_set_new_target()
		_state_logic(delta)
		var transition = _get_transition(delta)
		if transition != null:
			set_state(transition)
			
func _state_logic(delta):
	pass
	
func set_state(new_state):
	if new_state != states.crash and (not canChangeState or not enabled): 
		return
		
	prev_state = state
	state = new_state
	
	if prev_state != null:
		_exit_state(prev_state, new_state)
	if new_state != null:
#		for n in states:
#			if states[n] == new_state:
##				print(" #", parent.id, ", ", parent.display, ", _enter_state: " , n, " on frame: ", Engine.get_idle_frames())
#				if parent.has_node("Debug"):
#					parent.get_node("Debug/C/behav").text = n
#					break
		_enter_state(prev_state, new_state)
		parent.checkMoveTargetWithinBoundary()
		parent.update_debug_menu_entry_on_state_change()
		
func add_state(state_name):
	states[state_name] = states.size()
	state = states.size()
	
func _get_transition(delta):
	pass
		
func _exit_state(_prev_state, _new_state):
	pass
	
func _enter_state(_prev_state, _new_state):
	pass

#func setStartState(state):
#	for n in states.keys():
#		if str(n) == state:
#			set_state(states[state])
			
func do_init():
	set_state(states.wander)
