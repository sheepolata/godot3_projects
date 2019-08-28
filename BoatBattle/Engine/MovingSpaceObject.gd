extends KinematicBody2D

var collision_info : KinematicCollision2D = null

var planets_gravity : Vector2 = Vector2.ZERO

var gravity_influence_factor : float = 1.0

export(float) var hull_point_max : = 100.0
var hull_point : float

var is_dead = false

func _ready():
	hull_point = hull_point_max

func take_hull_damage(value : float) -> void:
	hull_point -= value
	if hull_point < 0:
		is_dead = true

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
			weighted_mean_gravity += planet.gravity
	
	if planets.size() > 0:
		weighted_mean_gravity /= planets.size()
	else:
		weighted_mean_gravity = 0
	
	collision_info = move_and_collide(planets_gravity * delta * weighted_mean_gravity)