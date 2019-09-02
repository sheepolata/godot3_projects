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
var accel = 0.5

var sender

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("ammo")
	$Lifespan.wait_time = life_span
	$Lifespan.start()
	$AnimationPlayer.play("fly")

func _physics_process(delta):
	
	match state:
		"DEFAULT":
			current_speed = min(speed, current_speed + (speed*(1.0/accel)*delta))
			collision_info = move_and_collide(Vector2(current_speed * cos(rotation), current_speed * sin(rotation)) * delta)
			
			if collision_info:
				state = "EXPLODE"
				var ok : bool = false
				for _t_group in target_groups:
					if _t_group in collision_info.collider.get_groups():
						ok = true
						break
				if ok:
					if collision_info.collider.has_method("take_hull_damage"):
						collision_info.collider.take_hull_damage(damage)
						if collision_info.collider.get("is_dead") and collision_info.collider.score_value > 0:
							if sender and sender.get("score") != null:
								#print("ADD SCORE")
								sender.score += collision_info.collider.score_value
								collision_info.collider.nullify_score()
		"EXPLODE":
			$AnimationPlayer.play("explode")
			yield($AnimationPlayer, "animation_finished")
			queue_free()

func _on_Lifespan_timeout():
	state = "EXPLODE"