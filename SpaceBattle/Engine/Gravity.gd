extends KinematicBody2D

var planets_gravity : Vector2 = Vector2.ZERO
var velocity : Vector2 = Vector2(0,0)
var ext_velocity : Vector2 = Vector2.ZERO

export(float) var gravity_influence_factor : float = 1.0

var collision_info : KinematicCollision2D = null

func grav_acceleration(pos1 : Vector2, pos2 : Vector2, G : float) -> Vector2:
	var direction : Vector2 = pos1 - pos2
	var length : float = sqrt(direction.x*direction.x + direction.y*direction.y)
	var normal : Vector2 = direction / length
	return normal*(G/pow(length, 2))
	
func step_euler(gravity_pool : Vector2, affected_body : PhysicsBody2D, G : float):
	var step = 8
	
	for i in range(step):
		if collision_info:
			break
		var dt = 1.0/step
#		print(gravity_pool, ", ", affected_body.position)
		var acc = grav_acceleration(gravity_pool, affected_body.position, G)
		
		velocity += acc*dt
#		affected_body.position += velocity*dt
		collision_info = move_and_collide((velocity + ext_velocity)*dt*gravity_influence_factor)

func planets_gravity_application(delta : float):
	var planets : = get_tree().get_nodes_in_group("planets")
#	var all_vel : Vector2 = Vector2.ZERO
	for planet in planets:
#		if planet.position.distance_to(position) < planet.gravity_distance:
	#		all_vel += step_euler(planet.position, self, planet.gravity)
		step_euler(planet.position, self, planet.gravity)
	
#	print(velocity)

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
