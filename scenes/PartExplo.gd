extends Node2D

var remLifeTime:float = 0.0
var delay:float = 0.0

func construct():
	pass

func _physics_process(delta):
	if delay >= 0:
		delay -= delta
		if delay < 0:
			visible = true
			for n in $Parts.get_children():
				n.one_shot = true
				n.emitting = true
#				remLifeTime = ($PartExplo.lifetime * 1.5) / $PartExplo.speed_scale
				remLifeTime = max(remLifeTime, n.lifetime * 1.5)
				
			if has_node("Sprite"):
				$Sprite.playing = true
			if is_set_as_toplevel():
				global_position = get_parent().global_position
		else:
			return
		
	remLifeTime -= delta
	if remLifeTime <= 0:
		queue_free()

func _ready():
	if delay > 0:
		visible = false
		for n in $Parts.get_children():
			n.one_shot = true
			n.emitting = true

func _on_Sprite_animation_finished():
	$Sprite.hide()
