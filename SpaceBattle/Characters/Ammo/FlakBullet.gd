extends "res://Characters/Ammo/Ammo.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	
	life_span += rand_range(-life_span*0.1, life_span*0.1)
	
	$Lifespan.wait_time = life_span
	$Lifespan.start()
	
	$CollisionShape2D.disabled = false

func _physics_process(delta):
	
	match state:
		"DEFAULT":
			if accel <= 0:
				current_speed = speed
			else:
				current_speed = min(speed, current_speed + (speed*(1.0/accel)*delta))
			collision_info = move_and_collide(Vector2(current_speed * cos(rotation), current_speed * sin(rotation)) * delta)
#			position.x += current_speed * cos(rotation) * delta
#			position.y += current_speed * sin(rotation) * delta
		"EXPLODE":
			if $ExplodeTimer.is_stopped():
				$ExplodeTimer.wait_time = $Particles2D.lifetime
				$Sprite.hide()
				$Area2D/CollisionShape2D.disabled = true
				$Particles2D.emitting = true
				$ExplodeTimer.start()

func _on_Area2D_body_entered(body):
	if state != "DEFAULT":
		return
	if sender == null or body == sender:
		return
	if "shield" in body.get_groups() and sender == body.get_parent():
		return
		
	explode_and_deal_damage(body)

func _on_Area2D_area_entered(area):
	if state != "DEFAULT":
		return
#	if "shield" in area.get_parent().get_groups():
#		explode()

func _on_ExplodeTimer_timeout():
	queue_free()
