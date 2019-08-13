extends "res://engine/entity.gd"

var move_timer_length = 15
var move_timer = 0

var damage = 0.25

#var max_health = 1

func _ready():
	._ready()
	
	speed = 40
	
	$anim.play("default")
	move_direction = dir.rand()
	
	max_health = 1
	health = max_health

func _physics_process(delta):
	movement_loop()
	damage_loop()
	
	if move_timer > 0:
		move_timer -= 1
	if move_timer == 0 or is_on_wall():
		move_direction = dir.rand()
		move_timer = move_timer_length
