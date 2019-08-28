extends "res://Engine/MovingSpaceObject.gd"

var move_direction = Vector2.ZERO
var current_speeds : Vector2 = Vector2.ZERO

export(int) var SPEED = 550
export(float, 0, 50) var SPEED_INCREMENT = 4
var current_speed_increment : float = 0
export var speed_increment_factor : float = 0.025
var current_speed_increment_factor : float = 0.05

var all_stop : bool = false

export(int, 0, 90) var TURN_SPEED = 80
export(float, 0, 1) var TURN_SPEED_INCREMENT = 8

var state = "DEFAULT"

#var collision_info : KinematicCollision2D = null

var is_dead = false

onready var cam = $Camera2D
var max_zoom_in = 1; var max_zoom_out = 2.0;

onready var trail_effect = $TrailEffect_node/TrailEffect

#var planets_gravity : Vector2 = Vector2.ZERO

#onready var anim = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	add_to_group("player")
	set_physics_process(true)
	
	trail_effect.start()
	#anim.play("bg_anim")

func _physics_process(delta : float):
	update()
	
	basic_control_loop()
	
	
	match(state):
		"DEFAULT":
			state_default(delta)
		"CRASH":
			crashing(delta)
		"DEAD":
			dead_state(delta)

			
func state_default(delta : float):
	var v = Utils.normalise(abs(current_speeds.y), max_zoom_in, max_zoom_out, 0, SPEED)
	cam.zoom = cam.zoom.linear_interpolate(Vector2(v, v), delta)
		
	move_controls_loop()
	
	apply_forces_from_planets(delta)
	movement_loop(delta)
	
	if collision_info:
		if "planets" in collision_info.collider.get_groups():
			current_speeds = Vector2.ZERO
			$CollisionShape2D.disabled = true
			state = "CRASH"

func movement_loop(delta : float):
	#var motion = move_direction.normalized() * SPEED
	#move_and_slide(motion, Vector2(0, 0))
	
	if current_speeds == Vector2.ZERO:
		all_stop = false
	
	if move_direction.x > 0:
		current_speeds.x = min(current_speeds.x + move_direction.x * TURN_SPEED_INCREMENT, TURN_SPEED)
	elif move_direction.x < 0:
		current_speeds.x = max(current_speeds.x + move_direction.x * TURN_SPEED_INCREMENT, -TURN_SPEED)
	elif all_stop:
		if current_speeds.x > 0:
			current_speeds.x = max(0, current_speeds.x - TURN_SPEED_INCREMENT)
		else:
			current_speeds.x = min(0, current_speeds.x + TURN_SPEED_INCREMENT)
	
	if move_direction.y > 0:
		if current_speed_increment == 0:
			current_speed_increment = speed_increment_factor
		else:
			current_speed_increment = min(SPEED_INCREMENT, current_speed_increment * (1+current_speed_increment_factor))
			
		current_speeds.y = min(current_speeds.y + move_direction.y * current_speed_increment, SPEED)
	elif move_direction.y < 0:
		if current_speed_increment == 0:
			current_speed_increment = speed_increment_factor
		else:
			current_speed_increment = min(SPEED_INCREMENT, current_speed_increment * (1+current_speed_increment_factor))
			
		current_speeds.y = max(current_speeds.y + move_direction.y * current_speed_increment, -SPEED)
	elif all_stop:
		current_speed_increment = 0
		if current_speeds.y > 0:
			current_speeds.y = max(0, current_speeds.y - SPEED_INCREMENT*2)
		else:
			current_speeds.y = min(0, current_speeds.y + SPEED_INCREMENT*2)
	
#	rotation_degrees += current_speeds.x * delta
	rotate(deg2rad(current_speeds.x) * delta)
	#print(current_speeds)
	
	collision_info = move_and_collide(Vector2(current_speeds.y * cos(rotation), current_speeds.y * sin(rotation)) * delta)

func basic_control_loop():
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	if Input.is_action_just_pressed("reset"):
		if get_tree().reload_current_scene() == 0:
			print("Reload OK")
		else:
			print("Reload went wrong")

func move_controls_loop():
	
	if Input.is_action_pressed("all_stop"):
		move_direction = Vector2.ZERO
		all_stop = true
		
	var LEFT	= Input.is_action_pressed("left")
	var RIGHT	= Input.is_action_pressed("right")
	var UP		= Input.is_action_pressed("up")
	var DOWN	= Input.is_action_pressed("down")
	
	move_direction.x = -int(LEFT) + int(RIGHT)
	move_direction.y = -int(DOWN) + int(UP)

func _on_WaterEffect_timeout():
	var this_effect = preload("res://Engine/WaveEffect.tscn").instance()
	#this_effect.min_scale = 0
	this_effect.max_scale = Utils.normalise(abs(current_speeds.y), this_effect.min_scale, this_effect.max_scale, 0, SPEED)
	
	trail_effect.wait_time = Utils.normalise(SPEED - abs(current_speeds.y), 0.1, 0.25, 0, SPEED)
	
	get_parent().add_child(this_effect)
	
	this_effect.position = to_global($TrailEffect_node/WaveEffectSpawnPoint.position)
	
	var this_effect2 = preload("res://Engine/WaveEffect.tscn").instance()
	#this_effect2.min_scale = 0
	this_effect2.max_scale = Utils.normalise(abs(current_speeds.y), this_effect.min_scale, this_effect2.max_scale, 0, SPEED)
	
	trail_effect.wait_time = Utils.normalise(SPEED - abs(current_speeds.y), 0.1, 0.25, 0, SPEED)
	
	get_parent().add_child(this_effect2)
	
	this_effect2.position = to_global($TrailEffect_node/WaveEffectSpawnPoint2.position)

func crashing(delta):
	cam.zoom = cam.zoom.linear_interpolate(Vector2(.45, .45), delta)
	rotate( deg2rad(TURN_SPEED * 2 * delta) )
	move_and_slide(position.direction_to(collision_info.collider.position) * collision_info.collider.gravity * 50 * delta)
	$CrashTween.interpolate_property(self, "scale", scale, Vector2(0.2, 0.2), 3.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$CrashTween.start()
	yield($CrashTween, "tween_completed")
	$Sprite.hide()
	is_dead = true
	state = "DEAD"

func dead_state(delta : float):
	cam.zoom = cam.zoom.linear_interpolate(Vector2(2.5, 2.5), delta*.1)

func _draw():
	if not is_dead:
		draw_line(Vector2.ZERO, (planets_gravity*150).rotated(-rotation), Color.red, 5)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	