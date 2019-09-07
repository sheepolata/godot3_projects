extends "res://Engine/Ship.gd"

export var rotation_speed = 15

var state = "DEFAULT"

func _ready():
	add_to_group("enemy")
	
	default_score_value = 100
	score_value = default_score_value
	
	hull_point_max = 500
	hull_point = hull_point_max
	
func _physics_process(delta):
	update()
	
	if is_dead:
		state = "EXPLODE"
		
	match state:
		"DEFAULT":
			rotate(deg2rad(rotation_speed) * delta)
			hull_point = min(hull_point + repair_factor*delta, hull_point_max)
		"EXPLODE":
			queue_free()
	
func take_hull_damage(value):
	.take_hull_damage(value)
#	print("%10.2f / %f" % [hull_point, hull_point_max])
	
func _draw():
	draw_circle(Vector2.ZERO, 128 * (hull_point/hull_point_max), Color(1, 0, 0, 0.35))
	
#	for t in $turrets.get_children():
##		draw_empty_circle(t.position, Vector2(t.turret_range, t.turret_range), Color(1, 0, 0, 0.5), 0.2, 1)
#		draw_circle(t.position, t.turret_range, Color(1, 0, 0, 0.02))
##		var r = t.get_node("AutotargetRange/CollisionShape2D"),shape.radius
##		$AutotargetRange/CollisionShape2D.shape.radius
##		draw_empty_circle(t.position, Vector2(r, r), Color(1, 0, 0, 0.5), 0.2, 1)



















