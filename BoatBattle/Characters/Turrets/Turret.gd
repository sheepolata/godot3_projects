extends Sprite

export(float) var laser_cooldown : float = 0
export(float) var laser_range : float = 600
export(float) var laser_duration : float = 0
export(float) var laser_damage : float = 10

export(Vector2) var laser_random_offset_limits : Vector2 = Vector2(0, 0)

func _ready():
	if laser_cooldown > 0:
		$LaserCooldown.wait_time = laser_cooldown
	if laser_duration > 0:
		$LaserDuration.wait_time = laser_duration

	
	$RayCast2D.position = $FirePoint.position
	
	if laser_range > 0:
		$RayCast2D.cast_to = Vector2(0, -laser_range)
	else:
		$RayCast2D.cast_to = get_local_mouse_position()
	
	$RayCast2D.enabled = false
	$RayCast2D.add_exception(get_parent())
	
	
func _process(delta):
	update()
	
	if $RayCast2D.is_colliding():
		if $RayCast2D.get_collider() and $RayCast2D.get_collider().has_method("take_hull_damage"):
			$RayCast2D.get_collider().take_hull_damage(laser_damage * delta)
	
func _draw():
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
	if ( ($LaserCooldown.is_stopped() or laser_cooldown <= 0) 
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
	
func _on_LaserCooldown_timeout():
	$LaserCooldown.stop()


func _on_LaserDuration_timeout():
	$RayCast2D.enabled = false
	if laser_cooldown > 0:
		$LaserCooldown.start()
	$LaserDuration.stop()
