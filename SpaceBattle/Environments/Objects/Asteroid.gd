extends "res://Engine/Ship.gd"

var rot_speed : float = 0.0

var fly_direction : Vector2 = Vector2.ZERO
var speed : float = 150

var STATE = "DEFAULT"

var force : float = 0

var min_scale : float = 0.6; var max_scale : float = 2.4;
var min_speed : float = 300; var max_speed : float = 650;
var min_hullpoint : float = 3; var max_hullpoint : float = 10;

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	add_to_group("asteroid")
	
	rot_speed = randf() * PI * .5
	
	var _scale = randf() * (max_scale - min_scale) + min_scale
	scale = Vector2(_scale, _scale)
	
	speed = rand_range(min_speed, max_speed)
	
	gravity_influence_factor = rand_range(1.0, 10.0)
	
	force = pow((1+scale.x), 2) + speed*0.01
	
	hull_point_max = Utils.normalise(_scale, 0, (max_hullpoint - min_hullpoint), min_scale, max_scale) + min_hullpoint
	hull_point = hull_point_max
	
	default_score_value = int(round(force))
	score_value = default_score_value

func _physics_process(delta):
	update()
	
	match(STATE):
		"DEFAULT":
			$Sprite.rotate(rot_speed * delta)
		
#			apply_forces_from_planets(delta)
#			planets_gravity_application(delta)
			
			collision_info = move_and_collide(Vector2(speed * cos(get_angle_to(fly_direction)), speed * sin(get_angle_to(fly_direction))) * delta)
#			ext_velocity = Vector2(speed * cos(get_angle_to(fly_direction)), speed * sin(get_angle_to(fly_direction))).normalized()
			
			var offset = 10.0
			fly_direction = fly_direction + Vector2(
												offset*cos(get_angle_to(fly_direction)), 
												offset*sin(get_angle_to(fly_direction))
												)
			
			if collision_info:
				if "planets" in collision_info.collider.get_groups():
					$CollisionShape2D.disabled = true
					STATE = "CRASH"
				elif "player" in collision_info.collider.get_groups():
					collision_info.collider.take_hull_damage(force)
					
					$CollisionShape2D.disabled = true
					STATE = "EXPLODE"
				elif "asteroid" in collision_info.collider.get_groups():
					if force > collision_info.collider.get("force"):
						if force > collision_info.collider.get("force")*1.2:
							collision_info.collider.set("STATE", "EXPLODE")
						else:
							var a2 = randf() * PI * 2
							collision_info.collider.set("fly_direction", 
															Vector2(collision_info.collider.position.x + 128 * cos(a2), 
																	collision_info.collider.position.y + 128 * sin(a2)))
					else:
						if force*1.2 < collision_info.collider.get("force"):
							set("STATE", "EXPLODE")
						else:
							var a = randf() * PI * 2
							fly_direction = Vector2(position.x + 128 * cos(a), position.y + 128 * sin(a))
			
			if is_dead:
				STATE = "EXPLODE"
		
		"CRASH":
			$Sprite.rotate( deg2rad(rot_speed * 2 * delta) )
			move_and_slide(position.direction_to(collision_info.collider.position) * collision_info.collider.gravity * delta * collision_info.collider.gravity/20)
			if not $Tween.is_active():
				$Tween.interpolate_property(self, "scale", scale, Vector2(0, 0), 3.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				$Tween.start()
		"EXPLODE":
			$CollisionShape2D.disabled = true
			queue_free()

func _on_Tween_tween_all_completed():
	STATE = "EXPLODE"
