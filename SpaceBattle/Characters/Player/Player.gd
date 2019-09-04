extends "res://Engine/MovingSpaceObject.gd"

var move_direction = Vector2.ZERO
var current_speeds : Vector2 = Vector2.ZERO

export(int) var speed_max = 800
export(float, 0, 50) var speed = 128

var thruster_stop : bool = false
var rotation_stop : bool = false

export(int, 0, 90) var turn_speed_max = 120
export(float) var turn_speed = 180

var score : int = 0 setget set_score

var state = "DEFAULT"

#var collision_info : KinematicCollision2D = null

onready var cam = $MainCamera
var max_zoom_in = 1.6; var max_zoom_out = 3.2;

onready var trail_effect = $TrailEffect_node/TrailEffect

onready var turrets : Array = $turrets.get_children()

export var front_missile = preload("res://Characters/Ammo/Missile1.tscn")
export(float) var front_missile_cd = 1.2
var front_aim : bool = false
export(float) var front_damage_bonus = 0

export var right_missile = preload("res://Characters/Ammo/FlakBullet.tscn")
export(float) var right_missile_cd = 1.2
var right_aim : bool = false
export(float) var right_damage_bonus = 0

export var left_missile = preload("res://Characters/Ammo/FlakBullet.tscn")
export(float) var left_missile_cd = 1.2
#export(PackedScene) var left_missile
var left_aim : bool = false
export(float) var left_damage_bonus = 0

var default_aim_front : Vector2 = Vector2.ZERO
var default_aim_left  : Vector2 = Vector2.ZERO
var default_aim_right : Vector2 = Vector2.ZERO

var front_aim_arc_angle = 15
var side_aim_arc_angle_low = 40; var side_aim_arc_angle_high = 170;

var _current_delta : float = 0
var previous_arc_transparancy : float = 0.0; var previous_aim_missile_transparancy : float = 0.0;


# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	randomize()
	
	
	
#	$ParallaxBackground.scale = Vector2(max_zoom_out, max_zoom_out)
	for pbg in $ParallaxBackground.get_children():
		if pbg is ParallaxLayer:
			for _sprite in pbg.get_children():
				if _sprite is Sprite:
					_sprite.scale = Vector2(max_zoom_out, max_zoom_out)
			pbg.motion_mirroring *= Vector2(max_zoom_out, max_zoom_out)
	
	add_to_group("player")
	set_physics_process(true)
	
	trail_effect.start()
	$UILayer/GravityDirection.rect_pivot_offset = $UILayer/GravityDirection.rect_size/2
	$UILayer/ScoreAdd.text = ""
	
	for t in turrets:
		t.autotarget_groups.append("asteroid")
		t.autotarget = true
	
	$missiles_front/Cooldown_front.wait_time = front_missile_cd
	$missiles_left/Cooldown_left.wait_time = left_missile_cd
	$missiles_right/Cooldown_right.wait_time = right_missile_cd
	
	for m in $missiles_front.get_children():
		if m is Timer:
			continue
		default_aim_front = m.cast_to
		break
	for m in $missiles_left.get_children():
		if m is Timer:
			continue
		default_aim_left = m.cast_to
		break
	for m in $missiles_right.get_children():
		if m is Timer:
			continue
		default_aim_right = m.cast_to
		break
	
func _physics_process(delta : float):
	_current_delta = delta
	
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
	$UILayer/VBoxContainer/SpeedInfo.rect_scale = Vector2(3, 3)
	
	$UILayer/VBoxContainer/HullPoints.text = "Hull : " + str(round((hull_point/hull_point_max) * 100)) + "%"
	$UILayer/VBoxContainer/HullPoints.rect_scale = Vector2(3, 3)
	
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
		
	var cd_text = ""
	if $missiles_front.get_child_count() > 0:
		var _text = "Front : "
		if $missiles_front/Cooldown_front.is_stopped():
			_text += "OK"
		else:
			var _t = "%.1fs"
			_t = _t % $missiles_front/Cooldown_front.time_left
			_text += _t
		cd_text += _text
		
	if $missiles_right.get_child_count() > 0:
		var _text = " Right : "
		if $missiles_right/Cooldown_right.is_stopped():
			_text += "OK"
		else:
			var _t = "%.1fs"
			_t = _t % $missiles_right/Cooldown_right.time_left
			_text += _t
		cd_text += _text
		
	if $missiles_left.get_child_count() > 0:
		var _text = " Left : "
		if $missiles_left/Cooldown_left.is_stopped():
			_text += "OK"
		else:
			var _t = "%.1fs"
			_t = _t % $missiles_left/Cooldown_left.time_left
			_text += _t
		cd_text += _text
	
	$UILayer/CooldownDisplay.text = cd_text

func collision_check():
	if collision_info:
		if collision_info.collider and "planets" in collision_info.collider.get_groups():
			current_speeds = Vector2.ZERO
			$CollisionShape2D.disabled = true
			state = "CRASH"
#		elif "asteroid" in collision_info.collider.get_groups():
#			print("OOPS")

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
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen

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
#		for t in turrets:
#			t.autotarget = false
#			t.fire()

	var relative_angle = rad2deg(get_angle_to(get_global_mouse_position()))
	if Input.is_action_pressed("aim_missiles"):
		if relative_angle > -front_aim_arc_angle and relative_angle < front_aim_arc_angle:
			front_aim = true
			right_aim = false
			left_aim = false
			for m in $missiles_front.get_children():
				if m is Timer:
					continue
				m.cast_to = default_aim_front.rotated(deg2rad(relative_angle))
#				print(m.cast_to)
		elif relative_angle >= side_aim_arc_angle_low and relative_angle < side_aim_arc_angle_high:
			front_aim = false
			right_aim = true
			left_aim = false
			for m in $missiles_right.get_children():
				if m is Timer:
					continue
				m.cast_to = default_aim_front.rotated(deg2rad(relative_angle))
#				print(m.cast_to)
		elif relative_angle <= -side_aim_arc_angle_low and relative_angle > -side_aim_arc_angle_high:
			front_aim = false
			right_aim = false
			left_aim = true
			for m in $missiles_left.get_children():
				if m is Timer:
					continue
				m.cast_to = default_aim_front.rotated(deg2rad(relative_angle))
		else:
			front_aim = false
			right_aim = false
			left_aim = false
	elif Input.is_action_just_released("aim_missiles"):
		front_aim = false
		right_aim = false
		left_aim = false
		for m in $missiles_front.get_children():
			if m is Timer:
				continue
			m.cast_to = default_aim_front
		for m in $missiles_left.get_children():
			if m is Timer:
				continue
			m.cast_to = default_aim_left
		for m in $missiles_right.get_children():
			if m is Timer:
				continue
			m.cast_to = default_aim_right
			
	if Input.is_action_pressed("fire_missiles"):
		if front_aim or (relative_angle > -front_aim_arc_angle and relative_angle < front_aim_arc_angle):
			if $missiles_front/Cooldown_front.is_stopped():
				for m in $missiles_front.get_children():
					if m is Timer:
						continue
					var rot = m.cast_to.angle() + rotation
					var missile = front_missile.instance()
					get_parent().add_child(missile)
					missile.position = m.global_position
					missile.speed += current_speeds.y
					missile.target_groups = ["asteroid", "enemy"]
					missile.my_rotation(rot)
					missile.sender = self
					missile.damage += front_damage_bonus
	
				$missiles_front/Cooldown_front.start()
		
		elif right_aim or (relative_angle >= side_aim_arc_angle_low and relative_angle < side_aim_arc_angle_high):
			if $missiles_right/Cooldown_right.is_stopped():
				for m in $missiles_right.get_children():
					if m is Timer:
						continue
					var rot = m.cast_to.angle() + rotation
					var missile = right_missile.instance()
					get_parent().add_child(missile)
					missile.position = m.global_position
					missile.speed += current_speeds.y
					missile.target_groups = ["asteroid", "enemy"]
					missile.my_rotation(rot)
					missile.sender = self
					missile.damage += right_damage_bonus
	
				$missiles_right/Cooldown_right.start()
		
		elif left_aim or (relative_angle <= -side_aim_arc_angle_low and relative_angle > -side_aim_arc_angle_high):
			if $missiles_left/Cooldown_left.is_stopped():
				for m in $missiles_left.get_children():
					if m is Timer:
						continue
					var rot = m.cast_to.angle() + rotation
					var missile = left_missile.instance()
					get_parent().add_child(missile)
					missile.position = m.global_position
					missile.speed += current_speeds.y
					missile.target_groups = ["asteroid", "enemy"]
					missile.my_rotation(rot)
					missile.sender = self
					missile.damage += left_damage_bonus
	
				$missiles_left/Cooldown_left.start()

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
#	var arc_display_distance = 4096;
	var _front = front_missile.instance()
	var arc_display_distance_front = _front.get("speed") * _front.get("life_span")
	_front.queue_free()
	var _right = right_missile.instance()
	var arc_display_distance_right = _right.get("speed") * _right.get("life_span")
	_right.queue_free()
	var _left = left_missile.instance()
	var arc_display_distance_left  = _left.get("speed")  * _left.get("life_span")
	_left.queue_free()
	var _t = min(0.1, previous_arc_transparancy + 0.1*_current_delta*(1/0.2))
	var _t2 = min(.5, previous_aim_missile_transparancy + .5*_current_delta*(1/0.2))
	var _cone_color = Color(1, 1, 1, _t)
	var _missile_aim_color = Color(1, 0, 0, _t2)
	previous_arc_transparancy = _t
	previous_aim_missile_transparancy = _t2
	
	if $missiles_front and front_aim:
		if not $missiles_front/Cooldown_front.is_stopped():
			_missile_aim_color.a /= 4
		for m in $missiles_front.get_children():
			if m is Timer:
				continue
			var rot = m.cast_to.angle()
			draw_line(m.position, Vector2(m.position.x + arc_display_distance_front*cos(rot), m.position.y + arc_display_distance_front*sin(rot)), _missile_aim_color, 5)
		
	if $missiles_left and left_aim:
		if not $missiles_left/Cooldown_left.is_stopped():
			_missile_aim_color.a /= 4
		for m in $missiles_left.get_children():
			if m is Timer:
				continue
			var rot = m.cast_to.angle()
			draw_line(m.position, Vector2(m.position.x + arc_display_distance_left*cos(rot), m.position.y + arc_display_distance_left*sin(rot)), _missile_aim_color, 5)
		
	if $missiles_right and right_aim:
		if not $missiles_right/Cooldown_right.is_stopped():
			_missile_aim_color.a /= 4
		for m in $missiles_right.get_children():
			if m is Timer:
				continue
			var rot = m.cast_to.angle()
			draw_line(m.position, Vector2(m.position.x + arc_display_distance_right*cos(rot), m.position.y + arc_display_distance_right*sin(rot)), _missile_aim_color, 5)
		
	if not right_aim and not left_aim and not front_aim:
		previous_aim_missile_transparancy = 0

	if Input.is_action_pressed("aim_missiles"):
	#	var front_aim_arc_angle = 15
	#	var side_aim_arc_angle_low = 35; var side_aim_arc_angle_high = 145;
		#Front arc
		var _avg : Vector2 = Vector2.ZERO; var count = 0;
		for m in $missiles_front.get_children():
			if m is Timer:
				continue
			_avg += m.position
			count += 1
		draw_circle_arc_poly(_avg/count, arc_display_distance_front, -front_aim_arc_angle+90, front_aim_arc_angle+90, _cone_color)
	
		#Side arcs
		_avg = Vector2.ZERO; count = 0;
		for m in $missiles_left.get_children():
			if m is Timer:
				continue
			_avg += m.position
			count += 1
		draw_circle_arc_poly(_avg/count, arc_display_distance_left, -side_aim_arc_angle_low+90, -side_aim_arc_angle_high+90, _cone_color)
	
		_avg = Vector2.ZERO; count = 0;
		for m in $missiles_right.get_children():
			if m is Timer:
				continue
			_avg += m.position
			count += 1
		draw_circle_arc_poly(_avg/count, arc_display_distance_right, side_aim_arc_angle_low+90, side_aim_arc_angle_high+90, _cone_color)
	else:
		previous_arc_transparancy = 0.0
		
func _on_CrashTween_tween_all_completed():
	$Sprite.hide()
	is_dead = true

func _on_Cooldown_right_timeout():
	$missiles_right/Cooldown_right.stop()

func _on_Cooldown_left_timeout():
	$missiles_left/Cooldown_left.stop()

func _on_Cooldown_front_timeout():
	$missiles_front/Cooldown_front.stop()

func _on_UILayer_ScoreAddDisplay_timeout(_timer):
	_timer.stop()
	$UILayer/ScoreAdd.text = ""

func set_score(value):
	var change = value - score
	score = value
	if change == 0:
		return
	
	$UILayer/ScoreAdd.text = "+"+str(change)
	$UILayer/ScoreAdd/ScoreAddDisplay.start(2.0)
	
	
	
	
	
	
	
	
	
	
	
	
	

