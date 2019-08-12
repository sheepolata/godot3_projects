extends KinematicBody2D

var speed = 70
var move_direction = Vector2(0, 0)

func _physics_process(delta):
	controls_loop()
	movement_loop()

func controls_loop():
	var LEFT	= Input.is_action_pressed("ui_left")
	var RIGHT	= Input.is_action_pressed("ui_right")
	var UP		= Input.is_action_pressed("ui_up")
	var DOWN	= Input.is_action_pressed("ui_down")
	
	move_direction.x = -int(LEFT) + int(RIGHT)
	move_direction.y = -int(UP) + int(DOWN)
	
func movement_loop():
	var motion = move_direction.normalized() * speed
	move_and_slide(motion, Vector2(0, 0))