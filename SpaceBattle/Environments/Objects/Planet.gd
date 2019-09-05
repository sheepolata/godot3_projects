tool
extends StaticBody2D

export(float) var angular_velocity : float = 0.3
var rotation_dir = 0
export(int) var gravity_distance : int = 2048
export(float) var gravity : float = 2000

func _ready():
	add_to_group("planets")
	
#	$CollisionShape2D.disabled = true
	
	randomize()
	
	var _scale = randf() * (1.2 - 0.8) + 0.8
	$Sprite.scale = Vector2(_scale, _scale)
	$CollisionShape2D.scale = Vector2(_scale, _scale) * 0.85
	
	rotation_dir = rand_range(-1, 1)
	angular_velocity = randf() * PI * 0.05
	
	rotate(randf()*PI)

func _process(delta):
	update()
	rotate(angular_velocity * delta * sign(rotation_dir))
	

var radius_factor_draw = 1.0
	
func _draw():
	if Engine.editor_hint:
		draw_circle(Vector2.ZERO, gravity_distance, Color(1.0, 1.0, 1.0, .1))
#	else:
#		radius_factor_draw -= 0.001
#		draw_empty_circle(Vector2.ZERO, Vector2(gravity_distance, gravity_distance)*radius_factor_draw, Color.blue, 0.1, 2.0)
#		if radius_factor_draw < 0.9:
#			radius_factor_draw = 1.0
		

func draw_empty_circle(circle_center : Vector2, circle_radius : Vector2, color : Color, resolution : float, width : float):
	var draw_counter = 1
	var line_origin = Vector2()
	var line_end = Vector2()
	line_origin = circle_radius + circle_center

	while draw_counter <= 360:
		line_end = circle_radius.rotated(deg2rad(draw_counter)) + circle_center
		draw_line(line_origin, line_end, color, width)
		draw_counter += 1 / resolution
		line_origin = line_end

	line_end = circle_radius.rotated(deg2rad(360)) + circle_center
	draw_line(line_origin, line_end, color, width)