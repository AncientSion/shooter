extends Camera2D

export var decay = 0.8  # How quickly the shaking stops [0, 1].
export var max_offset = Vector2(100, 75)  # Maximum hor/ver shake in pixels.
export var max_roll = 0.1  # Maximum rotation in radians (use sparingly).

export var smooth_speed: float = 3.0    # How fast the camera catches up
export var lead_distance: float = 0.65    # How much it peeks ahead (0.0 to 1.0)
export var zoom_speed: float = 1.8      # How fast the zoom changes
var min_lead_speed: float = 400
var target

onready var noise = OpenSimplexNoise.new()

var trauma = 0.0  # Current shake strength.
var trauma_power = 2  # Trauma exponent. Use [2, 3].
var noise_y = 0

func _ready():
	randomize()
	noise.seed = randi()
	noise.period = 4
	noise.octaves = 2
	
	target = Globals.PLAYER

func add_trauma(amount):
	print("traume: ", trauma)
	trauma = min(trauma + amount, 1.0)

func _physics_process(delta):
		
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()
		
	var ship_vel = target.velocity
	var current_speed = ship_vel.length()

	# 1. Calculate a Weight for the Lead
	# If speed is below min, lead_weight is 0. 
	# If above, it scales up.
	var lead_weight = 0.0
	if current_speed > min_lead_speed:
	# This creates a 0.0 to 1.0 range based on speed
	# You can also use 'clamp' to cap the lead effect
		lead_weight = (current_speed - min_lead_speed) / current_speed

	# 2. Apply the weighted lead
	var velocity_offset = ship_vel * (lead_distance * lead_weight)
	var target_pos = target.global_position + velocity_offset

	# 3. Interpolate Position
	global_position = global_position.linear_interpolate(target_pos, smooth_speed * delta)
	
	# 3. Dynamic Zoom#
	if Globals.curScene.level_type > 0:
		var speed_percent = target.velocity.length() / target.enginePower
		var target_zoom_val = 1.0 + (speed_percent * 0.4) # In Godot 3, higher is "further out"

		# Interpolating the zoom Vector2
		var target_zoom_vec = Vector2(target_zoom_val, target_zoom_val)
		self.zoom = self.zoom.linear_interpolate(target_zoom_vec, zoom_speed * delta)	
		Globals.ZOOM = self.zoom
		Globals.UI.get_node("Place/TopleftRighter/Difficulty/Vbox/Zoom/b").text = str("%.2f" % Globals.ZOOM.x)
	
		
func shake():
	var amount = pow(trauma, trauma_power)
	noise_y += 1
	rotation = max_roll * amount * noise.get_noise_2d(noise.seed, noise_y)
	offset.x = max_offset.x * amount * noise.get_noise_2d(noise.seed*2, noise_y)
	offset.y = max_offset.y * amount * noise.get_noise_2d(noise.seed*3, noise_y)
