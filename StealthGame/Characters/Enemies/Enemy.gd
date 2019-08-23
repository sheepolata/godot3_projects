
extends KinematicBody2D

onready var wait_timer: Timer = $Timer

export var editor_process: = false setget set_editor_process
export var speed: = 200.0
export var rotation_duration := 0.5

export var waypoint_path: = NodePath()

onready var waypoints : Waypoints = get_node(waypoint_path)

var target_position: = Vector2()

onready var fov = $FieldOfView

var can_move := false

var state : = "PATROL"
var targets : Array = []

var hit_pos
var target_visible : bool

func _ready():
	add_to_group("enemies")
	
	var shape = CircleShape2D.new()
	shape.radius = fov.view_radius
	$Detection/CollisionShape2D.shape = shape
	
	$Sprite.self_modulate.r = 0.5
	
	if not Engine.editor_hint:
		can_move = true
		#position = waypoints.get_start_position()
		
	if not waypoints:
		#set_physics_process(false)
		can_move = false
	else:
		position = waypoints.get_start_position()
		
		target_position = waypoints.get_next_point_position()
		look_at(target_position)
	
func _physics_process(delta : float):
	update()
	
	if rotation_degrees >= 360:
		rotation_degrees -= 360
	elif rotation_degrees <= -360:
		rotation_degrees += 360
		
	
	if targets.size() > 0:
		hit_pos = []
		var space_state = get_world_2d().direct_space_state
			
		var result : Dictionary = space_state.intersect_ray(position, targets[0].position, [self], collision_mask)
	
		if result:
			var _hit_pos = result.get("position")
			hit_pos.append(_hit_pos)
			var dir_to_target : Vector2 = (_hit_pos - position).normalized()
			
			if "detectable" in result.get("collider").get_groups() and abs(rad2deg(dir_to_target.angle_to(Directions.get_direction_angle(rotation)))) < fov.view_radius / 2.0:
				target_visible = true
				$Sprite.self_modulate.r = 1.0
			else:
				target_visible = false
				$Sprite.self_modulate.r = 0.5
	else:
		target_visible = false
		
	
	if target_visible:
		state = "ALARM"
	elif state != "PATROL":
		state = "PATROL"
	
	match state:
		"PATROL":		
			if can_move:
				var direction : = (target_position - position).normalized()
				var motion : = direction * speed * delta
				var distance_to_target = position.distance_to(target_position)
				
				if motion.length() > distance_to_target:
					position = target_position
					target_position = waypoints.get_next_point_position()
					
					var from = self.rotation_degrees
					var to = rad2deg(target_position.angle_to_point(global_position))
					if abs(from - to) > 180:
						to = 360 + to
					$Tween.interpolate_property(self, "rotation_degrees", from, to, rotation_duration, Tween.TRANS_LINEAR, Tween.EASE_OUT)
					$Tween.start()
					
					can_move = false
					wait_timer.start()
					
				else:
					position += motion
		"ALARM":
			if targets.size() > 0:
				var from = self.rotation_degrees
				var to = rad2deg(targets[0].position.angle_to_point(global_position))
				if abs(from - to) > 180:
					to = 360 + to
				$Tween.interpolate_property(self, "rotation_degrees", from, to, 0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
				$Tween.start()

func set_editor_process(value):
	editor_process = value
	
	if not Engine.editor_hint:
		return
	#set_physics_process(value)
	can_move = value
	wait_timer.stop()

func _draw():
	#draw_circle(Vector2.ZERO, fov.view_radius, Color(1, 1, 1, 0.25)) 
	
	#draw_line(Vector2.ZERO, Directions.point_from_angle_rad(Vector2.ZERO, deg2rad(-fov.view_angle / 2.0), fov.view_radius), Color(0, 0, 0, 0.25), 3.0)
	#draw_line(Vector2.ZERO, Directions.point_from_angle_rad(Vector2.ZERO, deg2rad(fov.view_angle / 2.0), fov.view_radius), Color(0, 0, 0, 0.25), 3.0)
	
	draw_field_of_view()
	
	if targets.size() > 0:
		for hit in hit_pos:
			draw_circle((hit - position).rotated(-rotation), 5, Color.red)
			draw_line(Vector2.ZERO, (hit - position).rotated(-rotation), Color.red, 2)

func draw_field_of_view() -> void:
	var step_count : int = int(round( fov.view_angle * fov.mesh_resolution ))
	var step_angle_size : float = fov.view_angle / step_count
	
	
	for i in range(step_count+1):
		var angle : float = rotation_degrees - fov.view_angle/2.0 + step_angle_size*i

		angle = deg2rad(90 + angle)

		draw_line(Vector2.ZERO, Directions.point_from_angle_rad(Vector2.ZERO, angle, fov.view_radius), Color.white)

func _on_Timer_timeout():
	#set_physics_process(true)
	can_move = true


func _on_Detection_body_entered(body):
	if targets.size() > 0 or not "detectable" in body.get_groups():
		return
	targets.append( body )
	
func _on_Detection_body_exited(body):
	var index = -1
	for i in range(targets.size()):
		if targets[i] == body:
			index = i
	if index != -1:
		targets.remove(index)
		$Sprite.self_modulate.r = 0.5




















