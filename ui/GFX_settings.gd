extends HBoxContainer

onready var res = $Resolution
onready var zoom = $Zoom
signal resolutionChange

func _ready():
	connectResolutionChange()
		
func connectResolutionChange():
	if Globals.curScene != null and not is_connected("resolutionChange", Globals.curScene, "_on_resolutionChange"):
		connect("resolutionChange", Globals.curScene, "_on_resolutionChange")

func disconnectResolutionChange():
	if is_connected("resolutionChange", Globals.curScene, "_on_resolutionChange"):
		disconnect("resolutionChange", Globals.curScene, "_on_resolutionChange")

func _on_Resolution_item_selected(index):
	var pick = Globals.reso_options[index]
	if Globals.SCREEN != pick:
		Globals.SCREEN = Globals.reso_options[index]
		emit_signal("resolutionChange")
		Globals.set_resolution()
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_EXPAND, Globals.SCREEN)
	
func _on_Zoom_item_selected(index):
	var pick:float = Globals.zoom_options[index]
	if Globals.ZOOM != Vector2(pick, pick):
		Globals.curScene.setZoom(Vector2(Globals.zoom_options[index], Globals.zoom_options[index]))
		emit_signal("resolutionChange")

func _on_Fullscreen_pressed():
	OS.window_fullscreen = !OS.window_fullscreen

func init_resolution():
	var index:int = -1
	for option in Globals.reso_options:
		index += 1
		var string = str(option.x, " x ", option.y)
		$Resolution.add_item(string)
		if Globals.SCREEN == option:
			$Resolution.selected = index

	index = -1
	for i in Globals.zoom_options:
		index += 1
		$Zoom.add_item(str(i))
		if Globals.ZOOM == Vector2(i, i):
			$Zoom.selected = i

	_on_Resolution_item_selected($Resolution.selected)
	_on_Zoom_item_selected($Zoom.selected)

	if Globals.curScene != null:
		Globals.curScene._on_resolutionChange()
