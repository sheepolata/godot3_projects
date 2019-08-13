extends "res://engine/entity.gd"

var state	= "default"
var keys	= 0

#var max_health = 3

func _ready():
	._ready()
	
	type = "player"
	set_physics_process(true)
	set_collision_mask_bit(1,0)
	
	speed = 70
	
	max_health = 3
	health = max_health

func _physics_process(delta):
	match state:
		"default":
			state_default()
		"swing":
			state_swing()
			
	keys = min(keys, 9)
	

func state_default():
	controls_loop()
	movement_loop()
	sprite_direction_loop()
	damage_loop()
	
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
		
	if Input.is_action_just_pressed("a"):
		use_item(preload("res://items/sword.tscn"))

func state_swing():
	anim_switch("idle_")
	movement_loop()
	damage_loop()
	move_direction = dir.center

func controls_loop():
	var LEFT	= Input.is_action_pressed("ui_left")
	var RIGHT	= Input.is_action_pressed("ui_right")
	var UP		= Input.is_action_pressed("ui_up")
	var DOWN	= Input.is_action_pressed("ui_down")
	
	move_direction.x = -int(LEFT) + int(RIGHT)
	move_direction.y = -int(UP) + int(DOWN)
	