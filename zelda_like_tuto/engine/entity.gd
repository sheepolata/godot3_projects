extends KinematicBody2D

var type = "ENEMY"
var speed = 0

var move_direction = dir.center
var knock_direction = dir.center
var sprite_direction = "down"

var hitstun = 0

var health = 1

func movement_loop():
	#var motion = move_direction.normalized() * speed
	#move_and_slide(motion, Vector2(0, 0))
	
	var motion
	if hitstun == 0:
		motion = move_direction.normalized() * speed
	else:
		motion = knock_direction.normalized() * speed * 1.5
	
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
		
func damage_loop():
	if hitstun > 0:
		hitstun -= 1
	for area in $hitbox.get_overlapping_areas():
		var body = area.get_parent()
		if hitstun == 0 and body.get("damage") != null and body.get("type") != type:
			health -= body.get("damage")
			hitstun = 10
			knock_direction = global_transform.origin - body.global_transform.origin

func use_item(item):
	var newitem = item.instance()
	newitem.add_to_group(str(newitem.get_name(), self))
	add_child(newitem)
	if get_tree().get_nodes_in_group(str(newitem.get_name(), self)).size() > newitem.max_amount:
		newitem.queue_free()


























