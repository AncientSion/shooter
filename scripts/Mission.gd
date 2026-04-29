extends Node2D

var logic: Node = null
var target_indicator:POI_MARKER = null
var inArea:bool = false

func _ready():
	# Optional: safety check
	if logic == null:
		push_warning("No mission logic attached!")

func set_mission_logic(m_logic: Node):
	logic = m_logic
	add_child(logic)

	# Optional: give logic access back to the scene
	if logic.has_method("set_owner"):
		logic.set_owner(self)

func _on_Area2D_area_entered(area):
#	print("_on_Area2D_area_entered, frame: ", Engine.get_idle_frames())
	if area.name != "Shield":
		logic.player_toggle_area_control()
	
func _on_Area2D_area_exited(area):
	if area.name != "Shield":
		logic.player_toggle_area_control()
