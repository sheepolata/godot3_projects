extends "res://engine/entity.gd"

func _ready():
	speed = 70

func _physics_process(delta):
	controls_loop()
	movement_loop()
	sprite_direction_loop()
	
	if is_on_wall() and move_direction != dir.center:
		if sprite_direction == "left" and test_move(transform, dir.left):
			anim_switch("push_")
		if sprite_direction == "right" and test_move(transform, dir.right):
			anim_switch("push_")
		if sprite_direction == "up" and test_move(transform, dir.up):
			anim_switch("push_")
		if sprite_direction == "down" and test_move(transform, dir.down):
			anim_switch("push_")
	elif move_direction != dir.center:
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
	