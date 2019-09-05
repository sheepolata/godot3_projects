extends "res://Engine/Gravity.gd"

export(float) var hull_point_max : = 100.0
var hull_point : float

var is_dead = false

var default_score_value : int = 0
var score_value : int = 0

func _ready():
	hull_point = hull_point_max

func take_hull_damage(value : float) -> void:
#	print("take " + str(value) + " dmg")
	hull_point = max(0, hull_point - value)
	if hull_point <= 0:
		is_dead = true


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

	
	
	
	
	
	