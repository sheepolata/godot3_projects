extends Sprite

export(float) var laser_cooldown : float = 1.0
export(float) var laser_range : float = 350
export(float) var laser_duration : float = 0.2

func _ready():
	$LaserCooldown.wait_time = laser_cooldown
	$LaserDuration.wait_time = laser_duration
	
	$RayCast2D.position = $FirePoint.position
	$RayCast2D.cast_to = Vector2(0, -laser_range)
	
func _process(delta):
	update()
	
func _draw():
	pass

func fire():
	if $LaserCooldown.is_stopped():
		
		
		$LaserCooldown.start()