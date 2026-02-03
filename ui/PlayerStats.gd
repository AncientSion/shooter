extends "res://ui/PanelItemStats.gd"

var ticks = int(1)

func _ready():
	pass
	
func _physics_process(delta):
	ticks += 1
	if ticks == 5:
		ticks = 0
		update_player_stats()


func update_player_stats():
#	var keys = ["Acceleration", "Velocity", "Boost", "BoostCharge", "Position", "Rotation". "Dist", "Mouse"]
	$VBox/VBox_Traits.get_node("rowAccel/value").text = str(round(player.accel.length()))
	$VBox/VBox_Traits.get_node("rowVelocity/value").text = str(round(player.velocity.length()))
	$VBox/VBox_Traits.get_node("rowBoost/value").text = str(player.boosting)
#	$VBox/VBox_Traits.get_node("rowBoostCharge/value").text = str(player.boostCharge)
	$VBox/VBox_Traits.get_node("rowBoostCharge/value").text = str("%.0f" % player.boostCharge)
	$VBox/VBox_Traits.get_node("rowPosition/value").text = str(int(player.global_position.x), " / " , int(player.global_position.y))
	$VBox/VBox_Traits.get_node("rowRotation/value").text = str(int(player.rotation_degrees))
	$VBox/VBox_Traits.get_node("rowShiftCooldown/value").text = str("%.2f" % player.shiftCooldown)
	$VBox/VBox_Traits.get_node("rowShiftDuration/value").text = str("%.2f" % player.shiftDuration)
	$VBox/VBox_Traits.get_node("rowDist/value").text = str(int(player.position.distance_to(Globals.MOUSE)))
	$VBox/VBox_Traits.get_node("rowMouse/value").text = str(round(Globals.MOUSE.x)) + " / " + str(round(Globals.MOUSE.y))
	$VBox/VBox_Traits.get_node("rowGrav/value").text = str(round(player.gravity_vec.x)) + " / " + str(round(player.gravity_vec.y))

