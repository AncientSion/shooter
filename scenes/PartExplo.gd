extends Node2D

var remLifeTime:float = 0.0
var delay:float = 0.0
var offset:Vector2 = Vector2.ZERO

func _ready():
#	print("ready explo")
#	print("pos", global_position)
	for n in $Parts.get_children():
		n.one_shot = true
		remLifeTime = max(remLifeTime, n.lifetime)
		
	if delay > 0:
		visible = false
		if has_node("Sprite"):
			$Sprite.playing = false
		for n in $Parts.get_children():
			n.emitting = false
#	else:
#		print("ding")
			
func construct(scale_f:float, delay_f:float = 0.0):
	scale = Vector2(scale_f, scale_f)
	delay = delay_f

func _physics_process(delta):
	if delay > 0:
		delay -= delta
		if delay < 0:
			visible = true
			if offset:
				position = get_parent().global_position + offset
			if has_node("Sprite"):
				$Sprite.playing = true
			for n in $Parts.get_children():
				if n.visible:
					n.emitting = true
#					remLifeTime = max(remLifeTime, n.lifetime * 1.2)
	else:
		remLifeTime -= delta
		if remLifeTime <= 0:
			queue_free()

func _on_Sprite_animation_finished():
	$Sprite.hide()
