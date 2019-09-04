extends KinematicBody2D

#var direction : Vector2 = Vector2.ZERO
export(float) var speed : float = 1000
var current_speed : float = 0
export(float) var life_span : float = 4
export(float) var damage = 50

var collision_info : KinematicCollision2D = null

var state = "DEFAULT"
var target_groups : Array = []

#How many second does if take to reach max speed
export(float) var accel = 0.5

export(float, 0, 180) var dispersion = 0

var sender

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("ammo")
	$Lifespan.wait_time = life_span
	$Lifespan.start()
	$AnimationPlayer.play("fly")
	
	$CollisionShape2D.disabled = true

func _physics_process(delta):
	
	match state:
		"DEFAULT":
			if accel <= 0:
				current_speed = speed
			else:
				current_speed = min(speed, current_speed + (speed*(1.0/accel)*delta))
#			collision_info = move_and_collide(Vector2(current_speed * cos(rotation), current_speed * sin(rotation)) * delta)
			collision_info = move_and_collide(Vector2(current_speed * cos(rotation), current_speed * sin(rotation)) * delta)
			
			if collision_info:
				print("WHY!?")
				var ok : bool = false
				for _t_group in target_groups:
					if _t_group in collision_info.collider.get_groups():
						ok = true
						break
				if ok:
					state = "EXPLODE"
					if collision_info.collider.has_method("take_hull_damage"):
						collision_info.collider.take_hull_damage(damage)
						if collision_info.collider.get("is_dead") and collision_info.collider.score_value > 0:
							if sender and sender.get("score") != null:
								#print("ADD SCORE")
								if "asteroid" in collision_info.collider.get_groups():
									sender.score += collision_info.collider.score_value * 2
								else:
									sender.score += collision_info.collider.score_value
								collision_info.collider.nullify_score()
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
	if "asteroid" in body.get_groups():
		state = "EXPLODE"
		body.take_hull_damage(damage)
		if body.score_value > 0:
			if sender and sender.get("score") != null:
				#print("ADD SCORE")
				if "asteroid" in body.get_groups():
					sender.score += body.score_value * 2
				else:
					sender.score += body.score_value
				body.nullify_score()
				
func my_rotation(angle):
	rotate(angle)
	rotate(deg2rad(rand_range(-dispersion, dispersion)))