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
var script_map_node_ref = null
var tween:SceneTreeTween = null

var id: String
var position: Vector2
var path_index: int  # Which pathway this node belongs to (0-2)
var node_index: int  # Position in the path sequence
var mission_class
var connections := []
var connections_lanes: = []
var ui_node:Node = null
var is_hovered:bool = false
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
#	if not is_selected and is_focused and can_be_selected:
#		$MC/VBox/C/Node_Sprite.rect_rotation += 360.0 * delta
	if not is_selected and can_be_selected:
		$MC/VBox/C/Node_Sprite.rect_rotation += 360.0 * delta
		
func do_complete():
	is_completed = true
	can_be_selected = false
	do_unselect_map_node()
	toggle_mission_quick_desc(false)

func do_selected_node_tween():
	tween = get_tree().create_tween()#.set_parallel(true)
	tween.tween_property($MC/VBox/C/Node_Sprite, "rect_scale", Vector2(1.7, 1.7), 0.5)
	tween.tween_property($MC/VBox/C/Node_Sprite, "rect_scale", Vector2(1.0, 1.0), 0.5)
	tween.tween_callback(self, "do_selected_node_tween")
#	tween.start()

func do_select_map_node():
	if Globals.MAP_SCENE.selected_node == null:
#		print(id)
		is_selected = true
		Globals.MAP_SCENE.selected_node = self
		$MC/VBox/C/Node_Sprite.rect_rotation = 0.0
		do_selected_node_tween()
		Globals.MAP_SCENE.show_selected_node_mission_details()
		toggle_mission_quick_desc(false)
#		show_node_mission_details()
	
func do_unselect_map_node():
#	print(id)
	is_selected = false
	Globals.MAP_SCENE.selected_node = null
	$MC/VBox/C/Node_Sprite.rect_scale = Vector2(1.0, 1.0)
	tween.stop()
	tween = null
	Globals.MAP_SCENE.hide_selected_node_mission_details()
	toggle_mission_quick_desc(true)
#	hide_node_mission_details()
	
func hide_node_mission_details():
	get_node("MC/VBox/PC_Details").hide()
	
func show_node_mission_details():
	get_node("MC/VBox/PC_Details").show()
			
func check_lane_highlight():
	if is_selected:
		return
		
	is_focused = !is_focused
	is_visible = !is_visible
	
	if is_selected or is_focused:
		for n in connections_lanes:
			n.self_modulate = Color(0, 1, 0)
	else:
		$MC/VBox/C/Node_Sprite.rect_rotation = 0
#		rect_scale = Vector2(1.0, 1.0)
		for n in connections_lanes:
			n.self_modulate = Color(1, 1, 1)
			
func toggle_mission_quick_desc(state:bool):
	get_node("MC/VBox/PC").visible = state

func _on_Node_Sprite_mouse_entered():
	check_lane_highlight()
	if is_selected == false:
		toggle_mission_quick_desc(true)

func _on_Node_Sprite_mouse_exited():
	check_lane_highlight()
	toggle_mission_quick_desc(false)

func _on_Node_Sprite_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if can_be_selected:
				if !is_selected:
					do_select_map_node()
				else:
					do_unselect_map_node()
