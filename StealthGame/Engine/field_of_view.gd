extends Node

class_name FieldOfView

export(float, 0, 3000) var view_radius : float = 160
export(float, 0, 360) var view_angle : float = 90
export(float, 0, 1) var mesh_resolution : float = 0.3
export(int) var edge_resolve_iteration : int = 6
export(float) var edge_distance_treshold : float = 1

func draw_field_of_view(global_position : Vector2) -> void:
	var step_count : int = int(round( view_angle * mesh_resolution ))
	var step_angle_size : float = view_angle / step_count
	
	#draw_line(Vector2.ZERO, Directions.point_from_angle_rad(Vector2.ZERO, deg2rad(0), fov.view_radius), Color.white)
	
	var view_points : Array = []
	
	var space_state = get_parent().get_world_2d().direct_space_state
	
	var previous_view_cast : Dictionary
	for i in range(step_count+1):
		var angle : float = 0 - view_angle/2.0 + step_angle_size*i
		angle = deg2rad(angle)

		var view_cast : Dictionary = view_cast(angle, global_position)
		
		if i > 0:
			var edge_dist_tresh_exceeded : bool = abs(previous_view_cast.get('dist') - view_cast.get('dist')) > edge_distance_treshold
			if (view_cast.get('hit') != previous_view_cast.get('hit') 
				or (view_cast.get('hit') and previous_view_cast.get('hit') and edge_dist_tresh_exceeded) ):
				var edge_info : Array = find_edge(previous_view_cast, view_cast, global_position)
				if edge_info[0] != Vector2.ZERO:
					view_points.append(edge_info[0])
					get_parent().draw_circle(edge_info[0], 5, Color.green)
				if edge_info[1] != Vector2.ZERO:
					view_points.append(edge_info[1])
					get_parent().draw_circle(edge_info[0], 5, Color.green)
		
		view_points.append(view_cast.get('point'))
		
		previous_view_cast = view_cast

		get_parent().draw_circle((view_cast.get('point')), 3, Color.red)
		get_parent().draw_line(Vector2.ZERO, (view_cast.get('point')), Color.red, 1)
		
		
	var nb_vertices = view_points.size() + 1
	var vertices = PoolVector2Array(); vertices.resize(nb_vertices);
	var triangles = []; triangles.resize((nb_vertices - 2) * 3);
	
	vertices[0] = Vector2.ZERO
	for i in range(nb_vertices - 1):
		vertices[i+1] = view_points[i]
		if i < nb_vertices-2:
			triangles[i*3] = 0
			triangles[i*3+1] = i + 1
			triangles[i*3+2] = i + 2
			
	#for v in vertices:
	#	draw_circle(v, 3, Color.red)
	#	draw_line(Vector2.ZERO, v, Color.red, 1)

	#draw_polygon(vertices, PoolColorArray([Color(1, 1, 1, 0.35)]))
	vertices.append(Vector2.ZERO)
	get_parent().draw_polyline(vertices, Color(1, 1, 1, 1), 2)

func find_edge(min_view_cast : Dictionary, max_view_cast : Dictionary, global_position : Vector2) -> Array:

	var min_angle : float = min_view_cast.get('angle')
	var max_angle : float = max_view_cast.get('angle')
	var min_point : Vector2 = Vector2.ZERO
	var max_point : Vector2 = Vector2.ZERO
	
	for i in range(edge_resolve_iteration):
		var angle : float = (min_angle + max_angle) / 2
		var new_view_cast : Dictionary = view_cast(angle, global_position)
		
		var edge_dist_tresh_exceeded : bool = abs(min_view_cast.get('dist') - new_view_cast.get('dist')) > edge_distance_treshold
		
		if new_view_cast.get('hit') == min_view_cast.get('hit') and not edge_dist_tresh_exceeded:
			min_angle = angle
			min_point = new_view_cast.get('point')
		else:
			max_angle = angle
			max_point = new_view_cast.get('point')
	
	return [min_point, max_point]

func view_cast(angle : float, global_position : Vector2) -> Dictionary:
	var result : Dictionary = {}
	
	var space_state = get_parent().get_world_2d().direct_space_state
	var ray_cast : Dictionary = space_state.intersect_ray(global_position, get_parent().to_global(Directions.point_from_angle_rad(Vector2.ZERO, angle, view_radius)), [get_parent()], get_parent().collision_mask)
	
	#draw_circle(Directions.point_from_angle_rad(Vector2.ZERO, angle, fov.view_radius), 5.0, Color(0, 0, 1, 0.25))
	#draw_line(Vector2.ZERO, Directions.point_from_angle_rad(Vector2.ZERO, angle, fov.view_radius), Color.red, 3)
	if ray_cast:
		result['hit'] = true
		result['point'] = get_parent().to_local(ray_cast.get('position'))
		
		#result['dist'] = global_position.distance_to(ray_cast.get('position'))
		result['dist'] = Vector2.ZERO.distance_to(result['point'])
		result['angle'] = angle
	else:
		result['hit'] = false
		result['point'] = Directions.point_from_angle_rad(Vector2.ZERO, angle, view_radius)
		result['dist'] = view_radius
		result['angle'] = angle
	
	return result