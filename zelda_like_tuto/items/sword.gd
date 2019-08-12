extends Node2D

var type = null
var damage = 1

var max_amount = 1

func _ready():
	type = get_parent().type
	$anim.connect("animation_finished", self, "destroy")
	$anim.play(str("swing_", get_parent().sprite_direction))
	if get_parent().has_method("state_swing"):
		get_parent().state = "swing"
	
func destroy(animation):
	if get_parent().has_method("state_swing"):
		get_parent().state = "default"
	queue_free()