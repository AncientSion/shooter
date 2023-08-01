extends Control

onready var entry = $VBox/VBox_Traits/Hbox
onready var player = Globals.PLAYER

func _ready():
	entry.get_node("key").text = ""
	entry.get_node("value").text = ""
	entry.hide()

func addEntry(key, value):
#	print(key)
	var newEntry = get_node("VBox/VBox_Traits/Hbox").duplicate()
	newEntry.show()
	get_node("VBox/VBox_Traits/Hbox").get_parent().add_child(newEntry)
	newEntry.name = str("row", str(key))
	newEntry.get_node("key").text = str(key)
	
#	print(key, " - ", value, " - ", typeof(value))
	if key == "":
		return
	elif key == "Shieldbreak cooldown" or key == "Shieldregen timer":
		newEntry.get_node("value").text = "%.2f" % value
	else:
		newEntry.get_node("value").text = str(value)
		
func showandfadeout():
	show()
	set_modulate("ffffff")
	$Timer.start()

func _on_Timer_timeout():
	$Tween.interpolate_property(self, "modulate:a",
			1, 0, 1,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			
	$Tween.start()
