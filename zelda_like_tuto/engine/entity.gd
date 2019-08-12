extends KinematicBody2D

var speed = 0

var move_direction = dir.center
var sprite_direction = "down"

func movement_loop():
	var motion = move_direction.normalized() * speed
	move_and_slide(motion, Vector2(0, 0))
	
func sprite_direction_loop():
	match move_direction:
		dir.left:
			sprite_direction = "left"
		dir.right:
			sprite_direction = "right"
		dir.up:
			sprite_direction = "up"
		dir.down:
			sprite_direction = "down"

func anim_switch(animation):
	var newanim = str(animation, sprite_direction)
	if $anim.current_animation != newanim:
		$anim.play(newanim)