extends "res://Characters/Ammo/Ammo.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	add_to_group("missile")
	$Lifespan.wait_time = life_span
	$Lifespan.start()
	$AnimationPlayer.play("fly")
	
	$CollisionShape2D.disabled = true

func _physics_process(delta):
	
	match state:
		"DEFAULT":
			
#			apply_forces_from_planets(delta)
#			planets_gravity_application(delta)
			
			if accel <= 0:
				current_speed = speed
			else:
				current_speed = min(speed, current_speed + (speed*(1.0/accel)*delta))
#			collision_info = move_and_collide(Vector2(current_speed * cos(rotation), current_speed * sin(rotation)) * delta)
			collision_info = move_and_collide(Vector2(current_speed * cos(rotation), current_speed * sin(rotation)) * delta)
			

		"EXPLODE":
			$SmokeParticles.hide()
			$SmokeParticles.emitting = false
			
			$CollisionShape2D.disabled = true
			
			$ExplosionParticles.emitting = true
			
			$AnimationPlayer.play("explode")
			yield($AnimationPlayer, "animation_finished")
			queue_free()

func _on_Lifespan_timeout():
	state = "EXPLODE"

func _on_Area2D_body_entered(body):
	if sender != null and body != sender:
		if state != "EXPLODE":
			state = "EXPLODE"
			body.take_hull_damage(damage)
			if  body.get("is_dead") and body.score_value > 0:
				if sender != null and sender.get("score") != null:
					sender.score += body.score_value
					body.nullify_score()
	elif "planet" in body.get_groups():
		if state != "EXPLODE":
			state = "EXPLODE"