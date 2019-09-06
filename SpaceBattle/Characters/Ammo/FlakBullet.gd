extends KinematicBody2D

#var direction : Vector2 = Vector2.ZERO
export(float) var speed : float = 1500
var current_speed : float = 0
export(float) var life_span : float = 1
export(float) var damage = 4

var collision_info : KinematicCollision2D = null

var state = "DEFAULT"
var target_groups : Array = []

#How many second does if take to reach max speed
export(float) var accel = 0

var sender

export(float, 0, 180) var dispersion = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("ammo")
	$Lifespan.wait_time = life_span
	$Lifespan.start()
	
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
			
		"EXPLODE":
			if $ExplodeTimer.is_stopped():
				$ExplodeTimer.wait_time = $Particles2D.lifetime
				$Sprite.hide()
				$CollisionShape2D.disabled = true
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
				if sender and sender.get("score") != null:
					sender.score += body.score_value
					body.nullify_score()

				
func my_rotation(angle):
	rotate(angle)
	rotate(deg2rad(rand_range(-dispersion, dispersion)))

func _on_ExplodeTimer_timeout():
	queue_free()
