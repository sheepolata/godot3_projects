extends KinematicBody2D

var collision_info : KinematicCollision2D = null

var planets_gravity : Vector2 = Vector2.ZERO

var gravity_influence_factor : float = 1.0

export(float) var hull_point_max : = 100.0
var hull_point : float

var is_dead = false

var default_score_value : int = 0
var score_value : int = 0

func _ready():
	hull_point = hull_point_max

func take_hull_damage(value : float) -> void:
	hull_point = max(0, hull_point - value)
	if hull_point <= 0:
		is_dead = true
#	print(hull_point, "hp")

func apply_forces_from_planets(delta : float):
	planets_gravity = Vector2.ZERO
	
	var weighted_mean_gravity = 0

	var planets : = get_tree().get_nodes_in_group("planets")
	var sum_gravities = 0
	for planet in planets:
		if planet.position.distance_to(position) < planet.gravity_distance:
			sum_gravities += planet.gravity
		
	for planet in planets:
		if planet.position.distance_to(position) < planet.gravity_distance:
			planets_gravity += position.direction_to(planet.position) * (planet.gravity/sum_gravities) * gravity_influence_factor
#			planets_gravity += position.direction_to(planet.position) * planet.gravity * (1 - (position.distance_to(planet.position) / planet.gravity_distance )) * gravity_influence_factor * (planet.gravity/sum_gravities)
			weighted_mean_gravity += planet.gravity
	
	if planets.size() > 0:
		weighted_mean_gravity /= planets.size()
	else:
		weighted_mean_gravity = 0
	
	collision_info = move_and_collide(planets_gravity * delta * weighted_mean_gravity)
#	collision_info = move_and_collide(planets_gravity * delta)

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

	
	
	
	
	
	