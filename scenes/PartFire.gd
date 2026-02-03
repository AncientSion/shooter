extends Node2D

var delay:float = 0.0
var offset:Vector2 = Vector2.ZERO
var noRota:bool = true

func _ready():
	if delay > 0:
		visible = false
		if has_node("Sprites/Main"):
			$Sprite.playing = false
		for n in $Parts.get_children():
			n.emitting = false
			
	for n in $Parts.get_children():
		n.one_shot = false
			
func construct(scale_f:float, delay_f:float = 0.0):
	scale = Vector2(scale_f, scale_f)
	delay = delay_f

func _physics_process(delta):
	if delay >= 0:
		delay -= delta
		if delay < 0:
			visible = true
			if offset:
				position = get_parent().global_position + offset
			if has_node("Sprites/Main"):
				$Sprites/Main.playing = true
			for n in $Parts.get_children():
				if n.visible:
					n.emitting = true
	elif noRota:
		global_rotation = 0
		
