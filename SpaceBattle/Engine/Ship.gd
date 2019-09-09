extends "res://Engine/Gravity.gd"

export(float) var hull_point_max : = 100.0
var hull_point : float

var is_dead = false

var default_score_value : int = 0
var score_value : int = 0

export(float) var speed = 0
var direction : float = 0

var repairs_available : bool = true
export(float) var repair_factor = 0.2

func _ready():
	add_to_group("ship")
	hull_point = hull_point_max

func take_damage(value : float) -> void:
#	print("take " + str(value) + " dmg")
#	if has_node("Shield"):
#		if get_node("Shield").active():
#			get_node("Shield").take_damage(value)
#			return
			
	hull_point = max(0, hull_point - value)
	if hull_point <= 0:
		is_dead = true
		
	if has_node("Camera2D"):
		get_node("MainCamera").shake_value = value
		get_node("MainCamera").shake_decrease = value*0.05

func nullify_score():
	score_value = 0
	
func draw_circle_arc( center, radius, angleFrom, angleTo, color ):
    var nbPoints = 32
    var pointsArc = PoolVector2Array()
    
    for i in range(nbPoints+1):
        var anglePoint = angleFrom + i*(angleTo-angleFrom)/nbPoints - 90
        var point = center + Vector2( cos(deg2rad(anglePoint)), sin(deg2rad(anglePoint)) )* radius
        pointsArc.push_back( point )
    
    for indexPoint in range(nbPoints):
        printt(indexPoint, pointsArc[indexPoint], pointsArc[indexPoint+1])
        draw_line(pointsArc[indexPoint], pointsArc[indexPoint+1], color)
    pass

func draw_circle_arc_poly( center, radius, angleFrom, angleTo, color ):
    var nbPoints = 32
    var pointsArc = PoolVector2Array()
    pointsArc.push_back(center)
    var colors = PoolColorArray([color])
    
    for i in range(nbPoints+1):
        var anglePoint = angleFrom + i*(angleTo-angleFrom)/nbPoints - 90
        pointsArc.push_back(center + Vector2( cos( deg2rad(anglePoint) ), sin( deg2rad(anglePoint) ) )* radius)
    draw_polygon(pointsArc, colors)
    pass

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
	
	
	
	
	
	