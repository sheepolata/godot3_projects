extends "res://Characters/Ammo/Ammo.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("ammo")
	
	life_span += rand_range(-life_span*0.1, life_span*0.1)
	
	$Lifespan.wait_time = life_span
	$Lifespan.start()

func _physics_process(delta):
	
	match state:
		"DEFAULT":
			if accel <= 0:
				current_speed = speed
			else:
				current_speed = min(speed, current_speed + (speed*(1.0/accel)*delta))
#			collision_info = move_and_collide(Vector2(current_speed * cos(rotation), current_speed * sin(rotation)) * delta)
			collision_info = move_and_collide(Vector2(current_speed * cos(rotation), current_speed * sin(rotation)) * delta)
			
		"EXPLODE":
			if $ExplodeTimer.is_stopped():
				$ExplodeTimer.wait_time = $Particles2D.lifetime
				$Sprite.hide()
				$Area2D/CollisionShape2D.disabled = true
				$Particles2D.emitting = true
				$ExplodeTimer.start()

func _on_Lifespan_timeout():
	if state != "EXPLODE":
		state = "EXPLODE"

func _on_Area2D_body_entered(body):
	if sender != null and body != sender:
		if state != "EXPLODE":
			state = "EXPLODE"
			body.take_hull_damage(damage)
			if body.get("is_dead") and body.score_value > 0:
				if sender != null and sender.get("score") != null:
					sender.score += body.score_value
					body.nullify_score()

func _on_ExplodeTimer_timeout():
	queue_free()
