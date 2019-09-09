extends Sprite

export(float) var laser_cooldown : float = 0
export(float) var turret_range : float = 600
export(float) var laser_duration : float = 0
export(float) var laser_damage : float = 10
export(float) var rotation_speed : float = 180
export(PackedScene) var bullet : PackedScene = null
export(float) var bullet_cd : float = 0.2

export(Vector2) var laser_random_offset_limits : Vector2 = Vector2(0, 0)

export(float) var damage_bonus_multiplier : float = 1.0

export(float) var turret_dispersion : float = 0

export var autotarget : bool = false
export var autotarget_groups : Array = []
var possible_autotargets : Array = []
var target_position : Vector2 = Vector2.ZERO
var autotarget_speed_factor : float = 1.0

func _ready():
	add_to_group("turret")
	
	if laser_cooldown > 0:
		$LaserCooldown.wait_time = laser_cooldown
	if laser_duration > 0:
		$LaserDuration.wait_time = laser_duration
	if bullet_cd > 0:
		$BulletCooldown.wait_time = bullet_cd

	
	$RayCast2D.position = $FirePoint.position
	
	if bullet == null:
		if turret_range > 0:
			$RayCast2D.cast_to = Vector2(0, -turret_range)
		else:
			$RayCast2D.cast_to = get_local_mouse_position()
	else:
		var _b = bullet.instance()
		turret_range = _b.speed * _b.life_span
		_b.queue_free()
	
	$RayCast2D.enabled = false
	$RayCast2D.add_exception(get_parent())
	$RayCast2D.add_exception(get_parent().get_parent())
	
	var shape = CircleShape2D.new()
	shape.radius = turret_range
	$AutotargetRange/CollisionShape2D.shape = shape
	
#	print($AutotargetRange/CollisionShape2D.shape.radius)
	
#	rotation = deg2rad(90)

var draw_actual_target : = Vector2.ZERO

func _process(delta):
	update()
	
	if not autotarget:
		target_position = get_global_mouse_position()
		var rot_delta = Utils.slide(0, rad2deg(get_angle_to(target_position)) + 90, (rotation_speed) * delta * autotarget_speed_factor)
		rotate(deg2rad(rot_delta))
	else:
		var _t = get_closest_target()
		if _t:
			target_position = _t.global_position
			
			if bullet != null:
				var _ammo_info = bullet.instance()
				var bullet_speed : float = _ammo_info.speed
				_ammo_info.free()
				var target_speed : float = 0
				if _t.get("current_speeds") != null:
					target_speed = _t.current_speeds.y
				else:
					target_speed = _t.speed
				var target_direction : float = _t.direction
				
				var dist_to_target : float = global_position.distance_to(target_position)
				var time_to_target : float = dist_to_target / bullet_speed
				
				var new_target : Vector2 = target_position + Vector2(
														target_speed*time_to_target*cos(deg2rad(target_direction)),
														target_speed*time_to_target*sin(deg2rad(target_direction))
													)
				
				
				target_position = new_target
				draw_actual_target = target_position
			
			var rot_delta = Utils.slide(0, rad2deg(get_angle_to(target_position)) + 90, (rotation_speed) * delta * autotarget_speed_factor)
			rotate(deg2rad(rot_delta))
			
			if autotarget and Utils.near(rad2deg(get_angle_to(target_position)), -90, 2):
				fire()
		else:
			draw_actual_target = Vector2.ZERO
	
			
	if $RayCast2D.is_colliding():
		if $RayCast2D.get_collider() and $RayCast2D.get_collider().has_method("take_damage"):
			$RayCast2D.get_collider().take_damage(laser_damage * delta)
			if $RayCast2D.get_collider().is_dead:
				if get_parent().get_parent().get("score") != null:
					get_parent().get_parent().score += $RayCast2D.get_collider().score_value
					$RayCast2D.get_collider().nullify_score()
	
func _draw():
	
#	draw_circle(Vector2.ZERO, $AutotargetRange/CollisionShape2D.shape.radius, Color(0, 1, 0, 0.25))
#	if draw_actual_target != Vector2.ZERO:
#		draw_circle(to_local(draw_actual_target), 5, Color.red)

	if $RayCast2D.enabled:
#		draw_line($RayCast2D.position, $RayCast2D.cast_to, Color.red, 3)
		if $RayCast2D.is_colliding() and $RayCast2D.get_collider():
#			print("HIT SMTH")
			draw_line($RayCast2D.position, to_local($RayCast2D.get_collision_point()), Color.red, 3)
			draw_circle(to_local($RayCast2D.get_collision_point()), 5, Color.red)
		else:
#			print("HIT NOTHING")
			draw_line($RayCast2D.position, $RayCast2D.cast_to, Color.red, 3)

func fire():
	if bullet != null and $BulletCooldown.is_stopped():
#		var rot = get_global_mouse_position().angle_to_point(global_position) 
		var rot = global_rotation - deg2rad(90)
		var ammo = bullet.instance()
		
#		get_parent().get_parent().get_parent().add_child(ammo)
		get_tree().get_nodes_in_group("world")[0].add_child(ammo)

		ammo.position = global_position + $RayCast2D.cast_to.rotated(rotation)
		if get_parent().get_parent().get("current_speeds"):
			ammo.speed += get_parent().get_parent().current_speeds.y
		ammo.target_groups = autotarget_groups
		ammo.dispersion += turret_dispersion
		ammo.initial_rotation(rot)
		ammo.sender = get_parent().get_parent()
		ammo.damage *= damage_bonus_multiplier
		
		ammo.add_collision_exception_with(get_parent().get_parent())
		
		$BulletCooldown.start()
		
	elif (bullet == null and ($LaserCooldown.is_stopped() or laser_cooldown <= 0) 
			and ($LaserDuration.is_stopped() or laser_duration <= 0)):
		$RayCast2D.enabled = true
		var rnd_offset = Vector2(rand_range(-laser_random_offset_limits.x/2, laser_random_offset_limits.x/2),
								rand_range(-laser_random_offset_limits.y/2, laser_random_offset_limits.y/2))
		if turret_range > 0:
			$RayCast2D.cast_to = Vector2(0, -turret_range)
		else:
			$RayCast2D.cast_to = get_local_mouse_position()
		$RayCast2D.cast_to += rnd_offset
		
		if laser_duration > 0:
			$LaserDuration.start()
		else:
			$LaserDuration.start(0.1)
	
func get_closest_target() -> PhysicsBody2D:
	if possible_autotargets.size() <= 0:
		return null
		
	possible_autotargets.sort_custom(self, "_compare_asteroid_distance")
	return possible_autotargets[0]

func _compare_asteroid_distance(a, b):
	return a.global_position.distance_to(global_position) < b.global_position.distance_to(global_position)

func _on_LaserCooldown_timeout():
	$LaserCooldown.stop()

func _on_LaserDuration_timeout():
	$RayCast2D.enabled = false
	if laser_cooldown > 0:
		$LaserCooldown.start()
	$LaserDuration.stop()

func _on_AutotargetRange_body_entered(body : PhysicsBody2D):
	if not body:
		return
		
	var valid = false
	for gr in autotarget_groups:
		if gr in body.get_groups():
#			print(gr)
			valid = true
			break
	if valid:
		possible_autotargets.append(body)

func _on_AutotargetRange_body_exited(body):
	if body:
		if body in possible_autotargets:
			possible_autotargets.remove(possible_autotargets.find(body))

func _on_BulletCooldown_timeout():
	$BulletCooldown.stop()

























