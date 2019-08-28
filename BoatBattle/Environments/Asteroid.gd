extends "res://Engine/MovingSpaceObject.gd"

var rot_speed : float = 0.0

var fly_direction : Vector2 = Vector2.ZERO
var speed : float = 150

var STATE = "DEFAULT"

var force : float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	add_to_group("asteroid")
	
	rot_speed = randf() * PI * .5
	
	var _scale = randf() * (0.8 - 0.2) + 0.2
	scale = Vector2(_scale, _scale)
	
	speed = randf() * (700 - 300) + 300
	
	gravity_influence_factor = randf() * (4.0 - 0.5) + 0.2
	
	force = pow((1+scale.x), 2) + speed*0.1

func _physics_process(delta):
	
	match(STATE):
		"DEFAULT":
			$Sprite.rotate(rot_speed * delta)
		
			apply_forces_from_planets(delta)
			
			collision_info = move_and_collide(Vector2(speed * cos(get_angle_to(fly_direction)), speed * sin(get_angle_to(fly_direction))) * delta)
			
			var offset = 10.0
			fly_direction = fly_direction + Vector2(
												offset*cos(get_angle_to(fly_direction)), 
												offset*sin(get_angle_to(fly_direction))
												)
			
			if collision_info:
				if "planets" in collision_info.collider.get_groups():
					$CollisionShape2D.disabled = true
					STATE = "CRASH"
				if "player" in collision_info.collider.get_groups():
					$CollisionShape2D.disabled = true
					STATE = "EXPLODE"
				if "asteroid" in collision_info.collider.get_groups():
					if force > collision_info.collider.get("force"):
						var a2 = randf() * PI * 2
						collision_info.collider.set("fly_direction", 
														Vector2(collision_info.collider.position.x + 128 * cos(a2), 
																collision_info.collider.position.y + 128 * sin(a2)))
						if force > collision_info.collider.get("force")*1.2:
							collision_info.collider.set("STATE", "EXPLODE")
					else:
						if force*1.2 < collision_info.collider.get("force"):
							set("STATE", "EXPLODE")
						var a = randf() * PI * 2
						fly_direction = Vector2(position.x + 128 * cos(a), position.y + 128 * sin(a))
		"CRASH":
			$Sprite.rotate( deg2rad(rot_speed * 2 * delta) )
			move_and_slide(position.direction_to(collision_info.collider.position) * collision_info.collider.gravity * delta * collision_info.collider.gravity/20)
			if not $Tween.is_active():
				$Tween.interpolate_property(self, "scale", scale, Vector2(0, 0), 3.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				$Tween.start()
		"EXPLODE":
			queue_free()

func _on_Tween_tween_all_completed():
	STATE = "EXPLODE"
