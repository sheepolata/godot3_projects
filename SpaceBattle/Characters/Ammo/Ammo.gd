extends KinematicBody2D

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

func _ready():
	add_to_group("ammo")

func explode():
	if state != "EXPLODE":
		state = "EXPLODE"

func explode_and_deal_damage(body):
	if state != "EXPLODE":
		state = "EXPLODE"
		body.take_hull_damage(damage)
		if body.get("is_dead") and body.score_value > 0:
			if sender != null and sender.get("score") != null:
				sender.score += body.score_value
				body.nullify_score()

func initial_rotation(angle):
	rotate(angle)
	rotate(deg2rad(rand_range(-dispersion, dispersion)))
	
func _on_Lifespan_timeout():
	if state != "EXPLODE":
		state = "EXPLODE"