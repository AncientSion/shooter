extends Control
class_name Map_Node
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var can_be_selected:bool = false
var is_completed:bool = false
var is_visible:bool = false
var is_focused:bool = false
var is_selected:bool = false
var is_player_position:bool = false
var is_behind:bool = false
var tween:SceneTreeTween = null

var id: String
var position: Vector2
var path_index: int  # Which pathway this node belongs to (0-2)
var node_index: int  # Position in the path sequence
var mission_class
var connections: Dictionary = {}
var is_hovered:bool = false
var is_tweening:bool = false
#var is_selected:bool = false

func do_init(node_id: String, node_position: Vector2, path_idx: int, node_idx: int, node_type):
	id = node_id
	position = Vector2(round(node_position.x), round(node_position.y))
	path_index = path_idx
	node_index = node_idx
	mission_class = node_type
	
func _ready():
	pass

func _process(delta):
	if is_selected:
		$MC/VBox/C/Node_Sprite.rect_rotation += 270.0 * delta
	elif can_be_selected and not is_tweening:
		is_tweening = true
		do_init_selected_node_tween()

func make_selectable():
	can_be_selected = true
	get_node("MC/VBox/C/Node_Sprite").modulate = Globals.RED

func set_as_behind():
	is_behind = true
	can_be_selected = false
	get_node("MC/VBox/C/Node_Sprite").modulate = Globals.WHITE
		
func reset_animation_state():
	if is_tweening:
		tween.stop()
	$MC/VBox/C/Node_Sprite.rect_rotation = 0.0
	$MC/VBox/C/Node_Sprite.rect_scale = Vector2(1.0, 1.0)
		
func do_complete():
	print("do_complete: ", name)
	is_completed = true
	is_behind = true
	can_be_selected = false
	is_tweening = false
	tween.stop()
	get_node("MC/VBox/C/Node_Sprite").modulate = Globals.GREEN
	do_unselect_map_node()
	toggle_mission_quick_desc(false)

func do_init_selected_node_tween():
	#print("do_init_selected_node_tween, node: ", name, ", tweening: ", is_tweening)
	
	tween = get_tree().create_tween()#.set_parallel(true)
	tween.tween_property($MC/VBox/C/Node_Sprite, "rect_scale", Vector2(2.0, 2.2), 0.5)
	tween.tween_property($MC/VBox/C/Node_Sprite, "rect_scale", Vector2(1.0, 1.0), 0.5)
	tween.tween_callback(self, "do_init_selected_node_tween")
#	tween.start()

func do_select_map_node():
	if Globals.MAP_SCENE.selected_node == null:
#		print(id)
		is_selected = true
		Globals.MAP_SCENE.selected_node = self
#		$MC/VBox/C/Node_Sprite.rect_rotation = 0.0
		#do_init_selected_node_tween()
		Globals.MAP_SCENE.show_selected_node_mission_details()
		toggle_mission_quick_desc(false)
	
func do_unselect_map_node():
#	print(id)
	is_selected = false
	Globals.MAP_SCENE.selected_node = null
#	tween.stop()
	$MC/VBox/C/Node_Sprite.rect_rotation = 0.0
#	$MC/VBox/C/Node_Sprite.rect_scale = Vector2(1.0, 1.0)
#	tween.stop()
#	tween = null
	Globals.MAP_SCENE.hide_selected_node_mission_details()
	toggle_mission_quick_desc(true)
	
func check_node_and_lane_highlight():
	if is_selected or is_completed or is_behind: return
	
#	print(id, ", x: ", position.x)
	is_focused = !is_focused
	is_visible = !is_visible
	
	if is_selected or is_focused:
		for n in connections:
			set_lane_color(connections[n], Globals.GREEN)
	else:
		$MC/VBox/C/Node_Sprite.rect_rotation = 0
#		rect_scale = Vector2(1.0, 1.0)
		for n in connections:
			set_lane_color(connections[n], Globals.WHITE)

func set_lane_color(lane, color):
	lane.self_modulate = color
			
func toggle_mission_quick_desc(state:bool):
	if is_completed: return
	get_node("MC/VBox/PC").visible = state

func _on_Node_Sprite_mouse_entered():
	if is_selected or is_completed or is_behind: return
	check_node_and_lane_highlight()
	if is_selected == false:
		toggle_mission_quick_desc(true)

func _on_Node_Sprite_mouse_exited():
	if is_selected or is_completed or is_behind: return
	check_node_and_lane_highlight()
	toggle_mission_quick_desc(false)

func _on_Node_Sprite_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if can_be_selected:
				if !is_selected:
					do_select_map_node()
				else:
					do_unselect_map_node()
