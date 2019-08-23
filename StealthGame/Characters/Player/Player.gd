extends KinematicBody2D

var move_direction = Vector2.ZERO
var SPEED = 400

var state = "DEFAULT"

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("player")
	set_physics_process(true)

func _physics_process(delta):
	
	look_at(get_global_mouse_position())
	
	#$Tween.interpolate_property(self, "rotation_degrees", self.rotation_degrees, rad2deg(self.global_position.angle_to_point(get_global_mouse_position())), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	#$Tween.start()
	
	#yield($Tween, "tween_all_completed")
	
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