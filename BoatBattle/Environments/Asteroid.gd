extends "res://Engine/MovingSpaceObject.gd"

var rot_speed : float = 0.0

var fly_direction : Vector2 = Vector2.ZERO
var speed : float = 150

var STATE = "DEFAULT"

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("asteroid")
	
	rot_speed = randf() * PI * .15
	
	var _scale = randf() * (1.0 - 0.2) + 0.2
	scale = Vector2(_scale, _scale)
	
	speed = randf() * (550 - 250) + 250
	
	gravity_influence_factor = randf() * (2.0 - 0.2) + 0.2

func _physics_process(delta):
	
	match(STATE):
		"DEFAULT":
			rotate(rot_speed * delta)
			
			apply_forces_from_planets(delta)
			
			collision_info = move_and_collide(Vector2(speed * cos(get_angle_to(fly_direction)), speed * sin(get_angle_to(fly_direction))) * delta)
			
			if collision_info:
				if "planets" in collision_info.collider.get_groups():
					$CollisionShape2D.disabled = true
					STATE = "CRASH"
				if "player" in collision_info.collider.get_groups():
					$CollisionShape2D.disabled = true
					STATE = "EXPLODE"
				if "asteroid" in collision_info.collider.get_groups():
					var a = randf() * PI * 2
					fly_direction = Vector2(0 + 128 * cos(a), 0 + 128 * sin(a))
					var a2 = randf() * PI * 2
					collision_info.collider.set("fly_direction", Vector2(0 + 128 * cos(a2), 0 + 128 * sin(a2)))
		"CRASH":
			rotate( deg2rad(rot_speed * 2 * delta) )
			move_and_slide(position.direction_to(collision_info.collider.position) * collision_info.collider.gravity * 50 * delta)
			$Tween.interpolate_property(self, "scale", scale, Vector2(0.2, 0.2), 3.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$Tween.start()
			yield($Tween, "tween_completed")
			STATE = "EXPLODE"
		"EXPLODE":
			queue_free()
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			