tool
extends Node2D

class_name Waypoints

export var editor_process : = true setget set_editor_process

export var line_color : = Color(0.228943, 0.710254, 0.945312)
export var triange_color : = Color(0.722656, 0.908997, 1)
export var line_width : = 10.0

var active_point_index : = 0

func _ready() -> void:
	if not Engine.editor_hint:
		set_process(false)
	
func _process(delta : float) -> void:
	update()

func get_start_position() -> Vector2:
	print("GET START POSITION")
	return get_child(0).global_position
	
func get_current_point_position() -> Vector2:
	return get_child(active_point_index).global_position
	
func get_next_point_position() -> Vector2:
	active_point_index = (active_point_index + 1) % get_child_count()
	return get_current_point_position()
	
func _draw() -> void:
	if not Engine.editor_hint:
		return
	if not get_child_count() > 1:
		return
		
	var points : = PoolVector2Array()
	var triangles : = []
	var last_point := Vector2.ZERO
	
	for child in get_children():
		points.append(child.position)
		
		if points.size() > 1:
			var center : Vector2 = (child.position + last_point) / 2
			var angle = last_point.angle_to_point(child.position)
			triangles.append({center=center, angle=angle})
		
		last_point = child.position
	points.append(get_child(0).position)
	
	draw_polyline(points, line_color, line_width, true)
	for tri in triangles:
		draw_triangle(tri['center'], tri['angle'], line_width * 2.0)
	
func draw_triangle(center : Vector2, angle : float, radius : float) -> void:
	var points : = PoolVector2Array()
	var colors : = PoolColorArray([triange_color])
	
	for i in range(3):
		var angle_point : = angle + i * 2.0 * PI / 3.0 + PI
		var offset : = Vector2(radius * cos(angle_point), radius * sin(angle_point))
		var point : = center + offset
		points.append(point)
	draw_polygon(points, colors)
	
func set_editor_process(value):
	editor_process = value
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	