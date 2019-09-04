extends Camera2D

var shake_value = 0
var shake_decrease = 0

func _process(delta):
	if shake_value > 0:
		offset = Vector2(rand_range(-shake_value, shake_value), rand_range(-shake_value, shake_value))
		shake_value -= shake_decrease
	