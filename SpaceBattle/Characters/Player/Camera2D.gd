extends Camera2D

var shake_value = 0
var shake_decrease = 0

export(float) var max_shake : float = 18.5
export(float) var damage_limit_up : float = 25

export(float) var aim_offset_factor : float = 0.15

onready var max_aim_offset_x : float = get_viewport_rect().size.x * aim_offset_factor
onready var max_aim_offset_y : float = get_viewport_rect().size.y * aim_offset_factor

func _process(delta):
	
	if Input.is_action_pressed("aim_missiles"):
		var aim_offset : Vector2 = get_aim_offset_from_mouse()
		offset = aim_offset
		
		#TODO Move cam offset toward aim_offset
	else:
		#TODO Move cam offset toward (0,0)
		pass
	
	if shake_value > 0:
		shake_value = clamp(shake_value, 0, max_shake)
		offset += Vector2(rand_range(-shake_value, shake_value), rand_range(-shake_value, shake_value))
		shake_value -= shake_decrease

func get_aim_offset_from_mouse() -> Vector2:
	var mouse_pos_viewport = get_viewport().get_mouse_position()
		
	var mouse_pos_viewport_relative_to_center = Vector2(
								mouse_pos_viewport.x - get_viewport_rect().size.x/2,
								mouse_pos_viewport.y - get_viewport_rect().size.y/2
							)
							
	var mouse_pos_normalised = Vector2(
								Utils.normalise(mouse_pos_viewport_relative_to_center.x, -1, 1, -get_viewport_rect().size.x/2, get_viewport_rect().size.x/2),
								Utils.normalise(mouse_pos_viewport_relative_to_center.y, -1, 1, -get_viewport_rect().size.y/2, get_viewport_rect().size.y/2)
							)
	
	var mouse_angle = mouse_pos_normalised.angle()
	var res : Vector2 = Vector2()
	res.x += max_aim_offset_x*abs(mouse_pos_normalised.x)*cos(mouse_angle)
	res.y += max_aim_offset_y*abs(mouse_pos_normalised.y)*sin(mouse_angle)
	
	return res

func apply_shake(value : float):
	var shake_normalised = Utils.normalise(value, 0, max_shake, 0, damage_limit_up)
	shake_value = shake_normalised
	shake_decrease = shake_value * 0.05