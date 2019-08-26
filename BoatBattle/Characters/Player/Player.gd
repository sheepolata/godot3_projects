extends KinematicBody2D

var move_direction = Vector2.ZERO
var current_speeds : Vector2 = Vector2.ZERO

export(int) var SPEED = 550
export(float, 0, 50) var SPEED_INCREMENT = 4

export(int, 0, 90) var TURN_SPEED = 90
export(float, 0, 1) var TURN_SPEED_INCREMENT = 3

var state = "DEFAULT"

var debug_dict : Dictionary = {}

var collision_info : KinematicCollision2D = null

onready var cam = $Camera2D
var max_zoom_in = 0.6; var max_zoom_out = 2;

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("player")
	set_physics_process(true)

func _physics_process(delta : float):
	update()
	
	var v = Utils.normalise(abs(current_speeds.y), max_zoom_in, max_zoom_out, 0, SPEED)
	cam.zoom = Vector2(v, v)
	
	match state:
		"DEFAULT":
			state_default(delta)
			
func state_default(delta : float):
	controls_loop()
	movement_loop(delta)
	
	if collision_info:
		pass

func movement_loop(delta : float):
	#var motion = move_direction.normalized() * SPEED
	#move_and_slide(motion, Vector2(0, 0))
	
	if move_direction.x > 0:
		current_speeds.x = min(current_speeds.x + move_direction.x * TURN_SPEED_INCREMENT, TURN_SPEED)
	elif move_direction.x < 0:
		current_speeds.x = max(current_speeds.x + move_direction.x * TURN_SPEED_INCREMENT, -TURN_SPEED)
	else:
		if current_speeds.x > 0:
			current_speeds.x = max(0, current_speeds.x - TURN_SPEED_INCREMENT*2)
		else:
			current_speeds.x = min(0, current_speeds.x + TURN_SPEED_INCREMENT*2)
	
	if move_direction.y > 0:
		current_speeds.y = min(current_speeds.y + move_direction.y * SPEED_INCREMENT, SPEED)
	elif move_direction.y < 0:
		current_speeds.y = max(current_speeds.y + move_direction.y * SPEED_INCREMENT, -SPEED)
	else:
		if current_speeds.y > 0:
			current_speeds.y = max(0, current_speeds.y - SPEED_INCREMENT*4)
		else:
			current_speeds.y = min(0, current_speeds.y + SPEED_INCREMENT*4)
	
	rotation_degrees += current_speeds.x * delta
	print(current_speeds)
	
	collision_info = move_and_collide(Vector2(current_speeds.y * cos(rotation), current_speeds.y * sin(rotation)) * delta)

func controls_loop():
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
		
	var LEFT	= Input.is_action_pressed("left")
	var RIGHT	= Input.is_action_pressed("right")
	var UP		= Input.is_action_pressed("up")
	var DOWN	= Input.is_action_pressed("down")
	
	move_direction.x = -int(LEFT) + int(RIGHT)
	move_direction.y = -int(DOWN) + int(UP)

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	