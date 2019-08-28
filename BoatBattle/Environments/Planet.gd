tool
extends StaticBody2D

export(float) var angular_velocity : float = 0.3
var rotation_dir = 0
export(int) var gravity_distance : int = 4096
export(float) var gravity : float = 50

func _ready():
	add_to_group("planets")
	
	randomize()
	
	var _scale = randf() * (1.2 - 0.8) + 0.8
	$Sprite.scale = Vector2(_scale, _scale)
	$CollisionShape2D.scale = Vector2(_scale, _scale) * 0.85
	
	rotation_dir = rand_range(-1, 1)
	angular_velocity = randf() * PI * 0.05
	
	rotate(randf()*PI)

func _process(delta):
	update()
	rotate(angular_velocity * delta * sign(rotation_dir))
	
	
func _draw():
	if Engine.editor_hint:
		draw_circle(Vector2.ZERO, gravity_distance, Color(1.0, 1.0, 1.0, .1))