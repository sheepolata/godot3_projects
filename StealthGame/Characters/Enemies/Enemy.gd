tool
extends KinematicBody2D

onready var wait_timer: Timer = $Timer

export var editor_process: = false setget set_editor_process
export var speed: = 200.0
export var rotation_duration := 0.5

export var waypoint_path: = NodePath()

onready var waypoints : Waypoints = get_node(waypoint_path)

var target_position: = Vector2()

var can_move := false

var set = false

func _ready():
	add_to_group("enemies")
	
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

func set_editor_process(value):
	editor_process = value
	
	if not Engine.editor_hint:
		return
	#set_physics_process(value)
	can_move = value
	wait_timer.stop()

func _on_Timer_timeout():
	#set_physics_process(true)
	can_move = true


func _on_Tween_tween_all_completed():
	if rotation_degrees >= 360:
		rotation_degrees -= 360
	elif rotation_degrees <= -360:
		rotation_degrees += 360
