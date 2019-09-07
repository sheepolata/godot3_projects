extends Camera2D

var shake_value = 0
var shake_decrease = 0

export(int) var max_shake : int = 25

func _process(delta):
	if shake_value > 0:
		shake_value = clamp(shake_value, 0, max_shake)
		offset = Vector2(rand_range(-shake_value, shake_value), rand_range(-shake_value, shake_value))
		shake_value -= shake_decrease
	