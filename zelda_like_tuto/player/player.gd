extends KinematicBody2D

var speed = 70
var move_direction = Vector2(0, 0)
var sprite_direction = "down"

func _physics_process(delta):
	controls_loop()
	movement_loop()
	sprite_direction_loop()
	
	if is_on_wall():
		if sprite_direction == "left" and test_move(transform, Vector2(-1, 0)):
			anim_switch("push_")
		if sprite_direction == "right" and test_move(transform, Vector2(1, 0)):
			anim_switch("push_")
		if sprite_direction == "up" and test_move(transform, Vector2(0, -1)):
			anim_switch("push_")
		if sprite_direction == "down" and test_move(transform, Vector2(0, 1)):
			anim_switch("push_")
	elif move_direction != Vector2(0,0):
		anim_switch("walk_")
	else:
		anim_switch("idle_")
	

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
	
func sprite_direction_loop():
	match move_direction:
		Vector2(-1, 0):
			sprite_direction = "left"
		Vector2(1, 0):
			sprite_direction = "right"
		Vector2(0, -1):
			sprite_direction = "up"
		Vector2(0, 1):
			sprite_direction = "down"

func anim_switch(animation):
	var newanim = str(animation, sprite_direction)
	if $anim.current_animation != newanim:
		$anim.play(newanim)