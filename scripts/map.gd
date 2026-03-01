extends Node

# Configuration properties
export var width:int = 1000.0
export var height:int = 600.0
export var path_count:int = 3  # Number of distinct pathways
export var min_nodes_per_path:int = 2
export var max_nodes_per_path:int = 4
#export var vertical_spacing:int = 150.0  # Space between paths
export var cross_path_probability := 0.15  # 15% chance for cross-path connections

const map_node = preload("res://scenes/Map_Node.tscn")

var selected_node = null
var all_shown:bool = false
var map_data:Dictionary
	
func _ready():
	$MC/PC/VBox/HBox/Menu/VBox/Min/Val.text = str($MC/PC/VBox/HBox/Menu/VBox/Min/Min_Slider.value)
	$MC/PC/VBox/HBox/Menu/VBox/Max/Val.text = str($MC/PC/VBox/HBox/Menu/VBox/Max/Max_Slider.value)
	$MC/PC/VBox/HBox/Menu/VBox/Branch/Val.text = str($MC/PC/VBox/HBox/Menu/VBox/Branch/Branch_Slider.value)
	$MC/PC/VBox/HBox/Menu/VBox/Cross_prob/Val.text = str($MC/PC/VBox/HBox/Menu/VBox/Cross_prob/Cross_Slider.value)
	
	$MC/PC/VBox/HBox/Location_Node.hide()
	$MC/PC/VBox/HBox/Location_Node/MC/VBox/PC.hide()
	
	$MC/PC/VBox/HBox/MAP/CC.hide()
		
func get_start_mission_type_dict():
	return Globals.handler_mission.get_start_mission()
	
func get_end_mission_type_dict():
	return Globals.handler_mission.get_end_mission()

func generate_3path_dag(map_params) -> Dictionary:
	randomize()
	
	var margin_x = 0.1
	width = map_params.get("width", 800)
	height = map_params.get("height", 600)
	path_count = map_params.get("rows", 3)
	min_nodes_per_path = map_params.get("min_nodes", 2)
	max_nodes_per_path = map_params.get("max_nodes", 4)
	cross_path_probability = map_params.get("cross_prob", 0.15)
	
	# Validate inputs
#	path_count = max(1, min(path_count, 3))  # Clamp between 1-3
	min_nodes_per_path = max(1, min_nodes_per_path)
	max_nodes_per_path = max(min_nodes_per_path, max_nodes_per_path)
	
	var nodes := {}
	var node_id := 0

	nodes["start"] = map_node.instance()
	nodes["start"].name = str("Node_", str(node_id))
	nodes["start"].do_init(
		"start",
		Vector2(width * margin_x, height / 2),
		-1,  # Not part of any pathF
		0,
		get_start_mission_type_dict()
	)
	
	# Create pathways
	var path_positions = _calculate_path_positions()
	
	for path_idx in path_count:
		var nodes_in_path = randi() % (max_nodes_per_path - min_nodes_per_path + 1) + min_nodes_per_path
		
		# Create nodes for this path
		for node_idx in range(nodes_in_path):
			var id = "path%d_node%d" % [path_idx, node_idx]
			node_id += 1
			
			# Calculate position along path
			var x_pos = width * 0.1 + (width * 0.8) * (node_idx + 1) / (nodes_in_path + 1)
			var y_pos = path_positions[path_idx]
			
			nodes[id] = map_node.instance()
			nodes[id].name = str("Node_", str(node_id))
			nodes[id].do_init(
				id,
				Vector2(x_pos, y_pos),
				path_idx,
				node_idx,
				Globals.handler_mission.get_random_mission()
			)
	
	# Create end node (centered)
	nodes["end"] = map_node.instance()
	nodes["end"].name = str("Node_", str(node_id+1))
	nodes["end"].do_init(
		"end",
		Vector2(width * (1.0 - margin_x), height / 2),
		-1,  # Not part of any path
		0,
		get_end_mission_type_dict()
	)
	
	# Connect nodes
	_connect_path_nodes(nodes)
	
	return {
		"nodes": nodes,
		"start_node_id": "start",
		"end_node_id": "end",
		"path_count": path_count
	}


func _add_cross_path_connections(nodes: Dictionary) -> void:
	# Group nodes by their horizontal progression (node_idx) and path
	var nodes_by_level = {}
	
	# Organize nodes by their horizontal level (node_idx)
	for node_id in nodes:
		var node = nodes[node_id]
		if node.path_index == -1:  # Skip start/end nodes
			continue
		
		if not nodes_by_level.has(node.node_index):
			nodes_by_level[node.node_index] = []
		nodes_by_level[node.node_index].append(node)
	
	# Get sorted levels
	var levels = nodes_by_level.keys()
	levels.sort()
	
	# For each horizontal level, check connections to nodes exactly one level ahead
	for i in range(levels.size() - 1):
		var current_level = levels[i]
		var next_level = levels[i + 1]
		
		# Only consider connections exactly one level forward
		if next_level != current_level + 1:
			continue
		
		for current_node in nodes_by_level[current_level]:
			for target_node in nodes_by_level[next_level]:
				# Only connect nodes on different paths
				if current_node.path_index == target_node.path_index:
					continue
				
				# Optional: Only connect adjacent paths
				if abs(current_node.path_index - target_node.path_index) != 1:
					continue
				
				# Random chance to connect (only from current -> target)
				if randf() < cross_path_probability:
					if not current_node.connections.has(target_node.id):
						current_node.connections.append(target_node.id)
#						print("Added cross-path connection: ", current_node.id, " -> ", target_node.id)

func _connect_path_nodes(nodes: Dictionary) -> void:
	# First connect sequential nodes within each path
	var path_nodes = {}
	
	# Group nodes by path
	for node_id in nodes:
		var node = nodes[node_id]
		if node.path_index == -1:  # Skip start/end nodes
			continue
		
		if not path_nodes.has(node.path_index):
			path_nodes[node.path_index] = []
		path_nodes[node.path_index].append(node)
	
	# Sort nodes in each path by their node_index and connect sequentially
	for path_idx in path_nodes:
		var path_node_list = path_nodes[path_idx]
#		path_node_list.sort_custom(func(a, b): return a.node_index < b.node_index)		
		path_node_list.sort_custom(self, "_sort_by_node_index")
		# Connect nodes in sequence (only one node forward)
		for i in range(path_node_list.size() - 1):
			var current_node = path_node_list[i]
			var next_node = path_node_list[i + 1]
			
			# Ensure we're only connecting to the immediate next node
			if next_node.node_index == current_node.node_index + 1:
				current_node.connections.append(next_node.id)
	
	# Connect start node to first nodes of each path (level 0 nodes)
	var start_node = nodes["start"]
	for path_idx in path_nodes:
		var first_node_in_path = path_nodes[path_idx].front()
		if first_node_in_path.node_index == 0:  # Only connect to level 0 nodes
			start_node.connections.append(first_node_in_path.id)
	
	# Connect last nodes of each path to end node
	var end_node = nodes["end"]
	for path_idx in path_nodes:
		var last_node_in_path = path_nodes[path_idx].back()
		last_node_in_path.connections.append(end_node.id)
	
	# Add cross-path connections (only one node forward)
	_add_cross_path_connections(nodes)

func _calculate_path_positions() -> Array:
#	var margin_y:float = 0.1
	var positions = []
	var center:float = height / 2
	var vertical_spacing:float = height / (path_count + 0)# + height*margin_y
	
	match path_count:
		1:
			positions.append(center)
		2:
			positions.append(center - vertical_spacing/2)
			positions.append(center + vertical_spacing/2)
		3:
			positions.append(center - vertical_spacing)
			positions.append(center)
			positions.append(center + vertical_spacing)
		4:
			positions.append(center - vertical_spacing * 1.5)
			positions.append(center - vertical_spacing * 0.5)
			positions.append(center + vertical_spacing * 0.5)
			positions.append(center + vertical_spacing * 1.5)
		5:
			positions.append(center - vertical_spacing * 2)
			positions.append(center - vertical_spacing)
			positions.append(center)
			positions.append(center + vertical_spacing)
			positions.append(center + vertical_spacing * 2)
	
	return positions

func _sort_by_x_position(a: Map_Node, b: Map_Node) -> bool:
	return a.position.x < b.position.x
	
func _sort_by_path_index(a: Map_Node, b: Map_Node) -> bool:
	return a.path_index < b.path_index
	
func _sort_by_node_index(a: Map_Node, b: Map_Node) -> bool:
	return a.node_index < b.node_index

func print_map_debug(map_data: Dictionary):
	print("=== 3-Path DAG Map ===")
	print("Paths: %d" % map_data["path_count"])
	print("Start: %s" % map_data["start_node_id"])
	print("End: %s" % map_data["end_node_id"])
	
	# Print nodes grouped by path
	for path_idx in range(path_count):
		print("\nPath %d:" % path_idx)
		var path_nodes = []
		
		for node in map_data["nodes"].values():
			if node.path_index == path_idx:
				path_nodes.append(node)
		
		path_nodes.sort_custom(self, "_sort_by_node_index")
		
		for node in path_nodes:
			print("  %s [%s] (Pos: %s) -> %s" % [
				node.id, node.mission_class, node.position, node.connections
			])
	
	# Print start and end
	print("\nStart Node Connections: %s" % map_data["nodes"]["start"].connections)
	print("End Node Connections: N/A")

func _on_Min_Slider_value_changed(value):
	$MC/PC/VBox/HBox/Menu/VBox/Min/Val.text = str(value)

func _on_Max_Slider_value_changed(value):
	$MC/PC/VBox/HBox/Menu/VBox/Max/Val.text = str(value)

func _on_Branch_Slider_value_changed(value):
	$MC/PC/VBox/HBox/Menu/VBox/Branch/Val.text = str(value)

func _on_Cols_Slider_value_changed(value):
	$MC/PC/VBox/HBox/Menu/VBox/Columns/Val.text = str(value)

func _on_Rows_Slider_value_changed(value):
	$MC/PC/VBox/HBox/Menu/VBox/Rows/Val.text = str(value)

func _on_Cross_Slider_value_changed(value):
	$MC/PC/VBox/HBox/Menu/VBox/Cross_prob/Val.text =  str("%.2f" % value)

func _on_Button_pressed():
	var width:int = $MC/PC/VBox/HBox/MAP.rect_size.x
	var height:int = $MC/PC/VBox/HBox/MAP.rect_size.y
	var min_nodes:int = $MC/PC/VBox/HBox/Menu/VBox/Min/Min_Slider.value
	var max_nodes:int = $MC/PC/VBox/HBox/Menu/VBox/Max/Max_Slider.value
	var branch_probability:float = $MC/PC/VBox/HBox/Menu/VBox/Branch/Branch_Slider.value
	var max_columns:int = $MC/PC/VBox/HBox/Menu/VBox/Columns/Cols_Slider.value
	var rows:int =  $MC/PC/VBox/HBox/Menu/VBox/Rows/Rows_Slider.value
	var cross_prob:float =  $MC/PC/VBox/HBox/Menu/VBox/Cross_prob/Cross_Slider.value
	
	var map_params = {
		"width": width,
		"height": height,
		"min_nodes": min_nodes,
		"max_nodes": max_nodes,
#		"branch_probability": branch_probability,
#		"max_columns": max_columns,
		"rows": rows,
		"cross_prob": cross_prob
	}
	
	for n in $MC/PC/VBox/HBox/MAP/P.get_children():
		n.queue_free()
	map_data = generate_3path_dag(map_params)
	
	create_lanes()
	create_locations()
	link_node_panels()
	fill_node_panel()
	draw_map()
	init_map()

func init_map():
	map_data.nodes["start"].can_be_selected = true
	return
	map_data.nodes["start"].do_select_map_node()

func link_node_panels():
	for entry in map_data.nodes:
		var node = map_data.nodes[entry]
		node.get_node("MC/VBox/PC/VBox/Type/B").text = node.mission_class.title
		node.get_node("MC/VBox/PC/VBox/Diffi/B").text = str(node.mission_class.difficulty)
		node.get_node("MC/VBox/PC/VBox/Reward/B").text = str(node.mission_class.reward)

func fill_node_panel():
	pass

func create_lanes():
	for entry in map_data.nodes:
		var node = map_data.nodes[entry]
		
		for connect in node.connections:
			var line = $MC/PC/VBox/HBox/Line2D.duplicate()
			node.connections_lanes.append(line)
			line.position = Vector2.ZERO
			
			var shorten:float = 0.13
			var leng = Vector2(map_data.nodes[connect].position - node.position).length()
			
			if leng < 130:
				shorten = .25
			elif leng > 200:
				shorten = .1
			
			var diff = (map_data.nodes[connect].position - node.position) * shorten
			var new_A = node.position + diff
			var new_B = map_data.nodes[connect].position - diff

			
#			line.points[0] = node.position
#			line.points[1] = map_data.nodes[connect].position
			line.points[0] = new_A
			line.points[1] = new_B
						
			$MC/PC/VBox/HBox/MAP/P.add_child(line)
			
func create_locations():
	for n in map_data.nodes:
		$MC/PC/VBox/HBox/MAP/P.add_child(map_data.nodes[n])

	
func draw_map():
	for entry in map_data.nodes:
		var node = map_data.nodes[entry]
		node.show()
#		var sprite_node_tree = node.ui_node
#		sprite_node_tree.show()
		node.rect_position = node.position
#		sprite_node_tree.rect_position = node.position
		
		for lanes in node.connections_lanes:
			lanes.show()
			
func fill_mission_overview_details():
	$MC/PC/VBox/Mission_Details_Confirm_Panel/Mission_Details/VBox/mission_desc/A.text = selected_node.mission_class.title
	$MC/PC/VBox/Mission_Details_Confirm_Panel/Mission_Details/VBox/mission_desc/B.text = selected_node.mission_class.desc
	$MC/PC/VBox/Mission_Details_Confirm_Panel/Mission_Details/VBox/Diffi/B.text = str(selected_node.mission_class.difficulty)
	$MC/PC/VBox/Mission_Details_Confirm_Panel/Mission_Details/VBox/Reward/B.text = str(selected_node.mission_class.reward)
	$MC/PC/VBox/Mission_Details_Confirm_Panel/Mission_Details/VBox/Hints/B.text = ""
	
func show_selected_node_mission_details():
	var path = selected_node.path_index
#	print(selected_node.script_map_node_ref.connections)
#	if path == 1:
#		$MC/PC/VBox/HBox/MAP/CC.size_flags_vertical = 0
#	elif path == 2:
#		$MC/PC/VBox/HBox/MAP/CC.size_flags_vertical = 4

	fill_mission_overview_details()
	$MC/PC/VBox/Mission_Details_Confirm_Panel.show()
	
func hide_selected_node_mission_details():
#	$MC/PC/VBox/HBox/MAP/Mission_Details_Confirm_Panel.size_flags_vertical = 4
	$MC/PC/VBox/Mission_Details_Confirm_Panel.hide()

func _on_Accept_pressed():
	Globals.GAMESCREEN.start_new_mission()
	
func _on_Cancel_pressed():
	print("cancel mission")
	if selected_node:
		var node = selected_node
		node.do_unselect_map_node()
		node._on_Node_Sprite_mouse_exited()
		
func do_progress():
	for node in map_data.nodes:
		if map_data.nodes[node].is_player_position and map_data.nodes[node].is_completed:
			for target in map_data.nodes[node].connections:
				for index in map_data.nodes:
					if index == target:
						map_data.nodes[index].can_be_selected = true
						break
						
#			print(map_data.nodes[node].connections) #connections_lanes
	
	

#func _on_Node_Sprite_mouse_exited():
#	check_lane_highlight()
#	get_parent().get_parent().get_node("PC").visible = false
