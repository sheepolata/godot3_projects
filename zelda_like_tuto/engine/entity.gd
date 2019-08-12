extends KinematicBody2D

var max_health = 2

var type = "enemy"
var speed = 0

var move_direction = dir.center
var knock_direction = dir.center
var sprite_direction = "down"

var health = max_health
var hitstun = 0

var texture_default = null
var texture_hurt = null

func _ready():
	if type == "enemy":
		set_physics_process(false)
		set_collision_mask_bit(1, 1)
	texture_default = $Sprite.texture
	texture_hurt = load($Sprite.texture.get_path().replace(".png", "_hurt.png"))
	
func movement_loop():
	#var motion = move_direction.normalized() * speed
	#move_and_slide(motion, Vector2(0, 0))
	
	var motion
	if hitstun == 0:
		motion = move_direction.normalized() * speed
	else:
		motion = knock_direction.normalized() * 125
	
	var r = move_and_slide(motion, Vector2(0, 0))
	
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
		$Sprite.texture = texture_hurt
	else:
		$Sprite.texture = texture_default
		if type == "enemy" and  health <= 0:
			var death_anim = preload("res://enemies/enemy_death.tscn").instance()
			get_parent().add_child(death_anim)
			death_anim.global_transform = get_global_transform()
			queue_free()
		
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


























