extends KinematicBody2D

var move_direction = Vector2.ZERO
var SPEED = 400

var state = "DEFAULT"

var debug_dict : Dictionary = {}

onready var camera = $Camera2D

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("player")
	add_to_group("detectable")
	set_physics_process(true)

func _physics_process(delta):
	update()
	
	look_at(get_global_mouse_position())

	offset_camera_from_mouse()
	
	match state:
		"DEFAULT":
			state_default()
			
func state_default():
	controls_loop()
	movement_loop()

func movement_loop():
	var motion = move_direction.normalized() * SPEED
	
	move_and_slide(motion, Vector2(0, 0))

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
	move_direction.y = -int(UP) + int(DOWN)


func offset_camera_from_mouse() -> void:
	
	var local_mouse : Vector2 = get_local_mouse_position()
	var dist_to_mouse : float = Vector2.ZERO.distance_to(local_mouse)
	var angle_to_mouse : float = Vector2.ZERO.angle_to(local_mouse)
	
	var offset_factor : float = 0.3
	
	var aspect_ratio = Globals.height / Globals.width
	
	camera.offset = Vector2(local_mouse.x * offset_factor, local_mouse.y * offset_factor * aspect_ratio).rotated(rotation).rotated(angle_to_mouse)

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	