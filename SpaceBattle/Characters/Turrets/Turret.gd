extends Sprite

export(float) var laser_cooldown : float = 0
export(float) var laser_range : float = 600
export(float) var laser_duration : float = 0
export(float) var laser_damage : float = 10
export(float) var rotation_speed : float = 180
export(PackedScene) var bullet : PackedScene = null
export(float) var bullet_cd : float = 0.2

export(Vector2) var laser_random_offset_limits : Vector2 = Vector2(0, 0)

var damage_bonus : float = 0

var autotarget : bool = false
var autotarget_groups : Array = []
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
	
	if laser_range > 0:
		$RayCast2D.cast_to = Vector2(0, -laser_range)
	else:
		$RayCast2D.cast_to = get_local_mouse_position()
	
	$RayCast2D.enabled = false
	$RayCast2D.add_exception(get_parent())
	$RayCast2D.add_exception(get_parent().get_parent())
	
	$AutotargetRange/CollisionShape2D.shape.radius = laser_range
	
#	rotation = deg2rad(90)
	
func _process(delta):
	update()
	
	var _t = get_closest_target()
	if not autotarget:
		 target_position = get_global_mouse_position()
	else:
		if _t:
			target_position = get_closest_target().position
	var _spd_factor
	if autotarget:
		_spd_factor = autotarget_speed_factor
#		look_at(target_position)
#		rotate(deg2rad(90))
	else:
		_spd_factor = 1.0
#		var rot_delta = Utils.slide(0, rad2deg(get_angle_to(target_position)) + 90, (rotation_speed) * delta)
#		rotate(deg2rad(rot_delta))
		
	var rot_delta = Utils.slide(0, rad2deg(get_angle_to(target_position)) + 90, (rotation_speed) * delta * _spd_factor)
	rotate(deg2rad(rot_delta))
	
	if autotarget and _t and Utils.near(rad2deg(get_angle_to(_t.position)), -90, 2):
		fire()
	
	if $RayCast2D.is_colliding():
		if $RayCast2D.get_collider() and $RayCast2D.get_collider().has_method("take_hull_damage"):
			$RayCast2D.get_collider().take_hull_damage(laser_damage * delta)
			if $RayCast2D.get_collider().is_dead:
				if get_parent().get_parent().get("score") != null:
					get_parent().get_parent().score += $RayCast2D.get_collider().score_value
					$RayCast2D.get_collider().nullify_score()
	
func _draw():
#	draw_circle(Vector2.ZERO, $AutotargetRange/CollisionShape2D.shape.radius, Color.green)
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
		var rot = rotation 
		var ammo = bullet.instance()
		add_child(ammo)
		
		ammo.position = position
		ammo.speed += get_parent().get_parent().current_speeds.y
		ammo.target_groups = ["asteroid", "enemy"]
		ammo.my_rotation(to_global($RayCast2D.cast_to).angle())
		ammo.sender = get_parent().get_parent()
		ammo.damage += damage_bonus
		
	elif ( ($LaserCooldown.is_stopped() or laser_cooldown <= 0) 
			and ($LaserDuration.is_stopped() or laser_duration <= 0)):
		$RayCast2D.enabled = true
		var rnd_offset = Vector2(rand_range(-laser_random_offset_limits.x/2, laser_random_offset_limits.x/2),
								rand_range(-laser_random_offset_limits.y/2, laser_random_offset_limits.y/2))
		if laser_range > 0:
			$RayCast2D.cast_to = Vector2(0, -laser_range)
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

























