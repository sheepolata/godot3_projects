extends "res://Engine/MovingSpaceObject.gd"

var move_direction = Vector2.ZERO
var current_speeds : Vector2 = Vector2.ZERO

export(int) var speed_max = 800
export(float, 0, 50) var speed = 128

var thruster_stop : bool = false
var rotation_stop : bool = false

export(int, 0, 90) var turn_speed_max = 120
export(float) var turn_speed = 180

var score : int = 0

var state = "DEFAULT"

#var collision_info : KinematicCollision2D = null

onready var cam = $Camera2D
var max_zoom_in = 1.6; var max_zoom_out = 3.2;

onready var trail_effect = $TrailEffect_node/TrailEffect

onready var turrets : Array = $turrets.get_children()

export(float) var front_missile_cd = 1.2
#export(PackedScene) var front_missile
var front_aim : bool = false

export(float) var right_missile_cd = 1.2
#export(PackedScene) var right_missile
var right_aim : bool = false

export(float) var left_missile_cd = 1.2
#export(PackedScene) var left_missile
var left_aim : bool = false

#var planets_gravity : Vector2 = Vector2.ZERO

#onready var anim = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	randomize()
	
	add_to_group("player")
	set_physics_process(true)
	
	trail_effect.start()
	$UILayer/GravityDirection.rect_pivot_offset = $UILayer/GravityDirection.rect_size/2
	
	for t in turrets:
		t.autotarget_groups.append("asteroid")
		t.autotarget = true
	
	$missiles_front/Cooldown_front.wait_time = front_missile_cd

func _physics_process(delta : float):
	update()
	
	basic_control_loop()
	
	update_UI(delta)
	
	collision_check()
	
	if is_dead:
		state = "DEAD"
	
	match(state):
		"DEFAULT":
			default_state(delta)
		"CRASH":
			crashing(delta)
		"DEAD":
			dead_state(delta)

func default_state(delta : float):
	var v = Utils.normalise(abs(current_speeds.y), max_zoom_in, max_zoom_out, 0, speed_max)
	cam.zoom = cam.zoom.linear_interpolate(Vector2(v, v), delta)
#	var d = Vector2(cos(rotation), sin(rotation))
#	cam.offset_h = d.x
#	cam.offset_v = d.y
		
	move_controls_loop()
	
	fire_control_loop()
	
	apply_forces_from_planets(delta)
	movement_loop(delta)

func update_UI(delta : float) -> void:
	$UILayer/VBoxContainer/SpeedInfo.text = (str(int(round(current_speeds.y))) + " spd, " 
								+ str(int(round(current_speeds.x))) + " deg"
							)
	if turrets.size() > 0:
		$UILayer/VBoxContainer/SpeedInfo.text = $UILayer/VBoxContainer/SpeedInfo.text + ", autofire " + str(turrets[0].autotarget)
		
	$UILayer/VBoxContainer/HullPoints.text = "Hull : " + str(round((hull_point/hull_point_max) * 100)) + "%"
	
	$UILayer/Score.text = str(score) + " Pts"
	
	if planets_gravity != Vector2.ZERO:
		$UILayer/GravityDirection.rect_scale = Vector2.ONE
		var gravity_angle = planets_gravity.angle()
		var _rot : Vector2 = Vector2($UILayer/GravityDirection.rect_rotation, $UILayer/GravityDirection.rect_rotation)
		_rot = _rot.linear_interpolate(Vector2(rad2deg(gravity_angle) + 90, rad2deg(gravity_angle) + 90), delta*10)
	#	$UILayer/GravityDirection.rect_rotation = _rot.x
		$UILayer/GravityDirection.rect_rotation = rad2deg(gravity_angle) + 90
	else:
		$UILayer/GravityDirection.rect_scale = Vector2.ZERO

func collision_check():
	if collision_info:
		if collision_info.collider and "planets" in collision_info.collider.get_groups():
			current_speeds = Vector2.ZERO
			$CollisionShape2D.disabled = true
			state = "CRASH"

func movement_loop(delta : float):
	#var motion = move_direction.normalized() * speed_max
	#move_and_slide(motion, Vector2(0, 0))
	
	if current_speeds.x == 0 and current_speeds.y != 0:
		rotation_stop = false
	elif current_speeds.y == 0 and current_speeds.x != 0:
		thruster_stop = false
			
	
	if move_direction.x > 0:
		current_speeds.x = min(current_speeds.x + move_direction.x * turn_speed * delta, turn_speed_max)
	elif move_direction.x < 0:
		current_speeds.x = max(current_speeds.x + move_direction.x * turn_speed * delta, -turn_speed_max)
	elif rotation_stop:
		if current_speeds.x > 0:
			current_speeds.x = max(0, current_speeds.x - turn_speed * delta * 2)
		else:
			current_speeds.x = min(0, current_speeds.x + turn_speed * delta * 2)
	
	if move_direction.y > 0:
		current_speeds.y = min(current_speeds.y + move_direction.y * speed * (1+(current_speeds.y/speed_max)*2) * delta, speed_max)
	elif move_direction.y < 0:
		current_speeds.y = max(current_speeds.y + move_direction.y * speed * (1+(current_speeds.y/speed_max)*2) * delta, -speed_max*.1)
	elif thruster_stop:
		if current_speeds.y > 0:
			current_speeds.y = max(0, current_speeds.y - speed * delta * 4)
		else:
			current_speeds.y = min(0, current_speeds.y + speed * delta * 4)
	
#	rotation_degrees += current_speeds.x * delta
	rotate(deg2rad(current_speeds.x) * delta)
	#print(current_speeds)
	
	collision_info = move_and_collide(Vector2(current_speeds.y * cos(rotation), current_speeds.y * sin(rotation)) * delta)

func basic_control_loop():
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	if Input.is_action_just_pressed("reset"):
		if get_tree().reload_current_scene() == 0:
			print("Reload OK")
		else:
			print("Reload went wrong")

func move_controls_loop():
		
	var LEFT	= Input.is_action_pressed("left")
	var RIGHT	= Input.is_action_pressed("right")
	var UP		= Input.is_action_pressed("up")
	var DOWN	= Input.is_action_pressed("down")
	
	move_direction.x = -int(LEFT) + int(RIGHT)
	move_direction.y = -int(DOWN) + int(UP)
	
	if LEFT or RIGHT:
		rotation_stop = false
	if UP or DOWN:
		thruster_stop = false
	if Input.is_action_pressed("all_stop"):
		move_direction.x = 0
		rotation_stop = true
		move_direction.y = 0
		thruster_stop = true
	elif Input.is_action_pressed("rotation_stop") :
		move_direction.x = 0
		rotation_stop = true
	elif Input.is_action_pressed("thruster_stop") :
		move_direction.y = 0
		thruster_stop = true

func fire_control_loop():
#	if Input.is_action_just_pressed("autotarget"):
#		for t in turrets:
#			t.autotarget = not t.autotarget
		
#	if Input.is_action_pressed("fire_turret"):
#		#print("HEY")
#		for t in turrets:
#			t.autotarget = false
#			t.fire()

	if Input.is_action_pressed("fire_missiles"):
		var relative_angle = get_angle_to(get_global_mouse_position())
		print(rad2deg(relative_angle))
		if relative_angle > -30 and relative_angle < 30:
			if $missiles_front/Cooldown_front.is_stopped():
				front_aim = true
		elif relative_angle >= 30:
			if $missiles_right/Cooldown_right.is_stopped():
				right_aim = true
		elif relative_angle <= -30:
			if $missile_left/Cooldown_left.is_stopped():
				left_aim = true
	
			
	if Input.is_action_just_released("fire_front"):
		front_aim = false
		if $missiles_front/Cooldown_front.is_stopped():
			for m in $missiles_front.get_children():
				if m is Timer:
					continue
#				var rot = m.global_position.angle_to_point(to_global(m.cast_to))# + rand_range(-deg2rad(rand_angle_front), deg2rad(rand_angle_front))
				var rot = m.cast_to.angle() + rotation
				var missile = preload("res://Characters/Ammo/Missile1.tscn").instance()
				get_parent().add_child(missile)
				missile.position = m.global_position
				missile.speed += current_speeds.y
				missile.target_groups = ["asteroid", "enemy"]
				missile.rotate(rot)
				missile.sender = self
				
			$missiles_front/Cooldown_front.start()
	elif Input.is_action_pressed("fire_front"):
		if $missiles_front/Cooldown_front.is_stopped():
			front_aim = true
			
	if Input.is_action_just_released("fire_right"):
		right_aim = false
		if $missiles_right/Cooldown_right.is_stopped():
			for m in $missiles_right.get_children():
				if m is Timer:
					continue
#				var rot = m.global_position.angle_to_point(to_global(m.cast_to))# + rand_range(-deg2rad(rand_angle_front), deg2rad(rand_angle_front))
				var rot = m.cast_to.angle() + rotation
				var missile = preload("res://Characters/Ammo/Missile1.tscn").instance()
				get_parent().add_child(missile)
				missile.position = m.global_position
				missile.speed += current_speeds.y
				missile.target_groups = ["asteroid", "enemy"]
				missile.rotate(rot)
				missile.sender = self
				
			$missiles_right/Cooldown_right.start()
	elif Input.is_action_pressed("fire_right"):
		if $missiles_right/Cooldown_right.is_stopped():
			right_aim = true
			
	if Input.is_action_just_released("fire_left"):
		left_aim = false
		if $missile_left/Cooldown_left.is_stopped():
			for m in $missile_left.get_children():
				if m is Timer:
					continue
#				var rot = m.global_position.angle_to_point(to_global(m.cast_to))# + rand_range(-deg2rad(rand_angle_front), deg2rad(rand_angle_front))
				var rot = m.cast_to.angle() + rotation
				var missile = preload("res://Characters/Ammo/Missile1.tscn").instance()
				get_parent().add_child(missile)
				missile.position = m.global_position
				missile.speed += current_speeds.y
				missile.target_groups = ["asteroid", "enemy"]
				missile.rotate(rot)
				missile.sender = self
				
			$missile_left/Cooldown_left.start()
	elif Input.is_action_pressed("fire_left"):
		if $missile_left/Cooldown_left.is_stopped():
			left_aim = true
			
func _on_WaterEffect_timeout():
	var this_effect = preload("res://Engine/WaveEffect.tscn").instance()
	#this_effect.min_scale = 0
	this_effect.max_scale = Utils.normalise(abs(current_speeds.y), this_effect.min_scale, this_effect.max_scale, 0, speed_max)
	
	trail_effect.wait_time = Utils.normalise(speed_max - abs(current_speeds.y), 0.1, 0.25, 0, speed_max)
	
	get_parent().add_child(this_effect)
	this_effect.position = to_global($TrailEffect_node/WaveEffectSpawnPoint.position)
#	this_effect.position = (position + $TrailEffect_node/WaveEffectSpawnPoint.position.rotated(rotation))
	
	var this_effect2 = preload("res://Engine/WaveEffect.tscn").instance()
	#this_effect2.min_scale = 0
	this_effect2.max_scale = Utils.normalise(abs(current_speeds.y), this_effect.min_scale, this_effect2.max_scale, 0, speed_max)
	
	trail_effect.wait_time = Utils.normalise(speed_max - abs(current_speeds.y), 0.1, 0.25, 0, speed_max)
	
	get_parent().add_child(this_effect2)
	
	this_effect2.position = to_global($TrailEffect_node/WaveEffectSpawnPoint2.position)

func crashing(delta):
	cam.zoom = cam.zoom.linear_interpolate(Vector2(.45, .45), delta)
	rotate( deg2rad(turn_speed_max * 2 * delta) )
	
#	var collider_pos : Vector2 = collision_info.collider.position
	
	move_and_slide(position.direction_to(collision_info.collider.position) * collision_info.collider.gravity * delta * collision_info.collider.gravity/20)
		
	if not $CrashTween.is_active():
		$CrashTween.interpolate_property(self, "scale", scale, Vector2(0.05, 0.05), 4, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$CrashTween.start()

func dead_state(delta : float):
	cam.zoom = cam.zoom.linear_interpolate(Vector2(max_zoom_out*2, max_zoom_out*2), delta*.1)
	$TrailEffect_node/TrailEffect.stop()
	hide()
	$CollisionShape2D.disabled = true
	for t in turrets:
		t.autotarget = false

func _draw():
	if front_aim:
		for m in $missiles_front.get_children():
			if m is Timer:
				continue
			var rot = m.cast_to.angle()
			draw_line(m.position, Vector2(m.position.x + 4096*cos(rot), m.position.y + 4096*sin(rot)), Color(1, 0, 0, .5), 3)
	
	if left_aim:
		for m in $missile_left.get_children():
			if m is Timer:
				continue
			var rot = m.cast_to.angle()
			draw_line(m.position, Vector2(m.position.x + 4096*cos(rot), m.position.y + 4096*sin(rot)), Color(1, 0, 0, .5), 3)
	
	if right_aim:
		for m in $missiles_right.get_children():
			if m is Timer:
				continue
			var rot = m.cast_to.angle()
			draw_line(m.position, Vector2(m.position.x + 4096*cos(rot), m.position.y + 4096*sin(rot)), Color(1, 0, 0, .5), 3)

func _on_CrashTween_tween_all_completed():
	$Sprite.hide()
	is_dead = true

func _on_Cooldown_right_timeout():
	$missiles_right/Cooldown_right.stop()

func _on_Cooldown_left_timeout():
	$missile_left/Cooldown_left.stop()

func _on_Cooldown_front_timeout():
	$missiles_front/Cooldown_front.stop()