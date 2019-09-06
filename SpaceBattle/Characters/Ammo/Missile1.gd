#extends KinematicBody2D
extends "res://Engine/Gravity.gd"

#var direction : Vector2 = Vector2.ZERO
export(float) var speed : float = 1000
var current_speed : float = 0
export(float) var life_span : float = 4
export(float) var damage = 50

var state = "DEFAULT"
var target_groups : Array = []

#How many second does if take to reach max speed
export(float) var accel = 0.5

export(float, 0, 180) var dispersion = 0

var sender

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("ammo")
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
			ext_velocity = Vector2(current_speed * cos(rotation), current_speed * sin(rotation)).normalized()

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
			if body.get("is_dead") and body.score_value > 0:
				if sender and sender.get("score") != null:
					sender.score += body.score_value
					body.nullify_score()
	elif "planet" in body.get_groups():
		if state != "EXPLODE":
			state = "EXPLODE"
				
func my_rotation(angle):
	rotate(angle)
	rotate(deg2rad(rand_range(-dispersion, dispersion)))