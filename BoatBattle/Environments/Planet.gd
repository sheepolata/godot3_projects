extends StaticBody2D

export(float) var angular_velocity : float = 0.3
var rotation_dir

func _ready():
	add_to_group("planets")
	
	randomize()
	
	rotation_dir = rand_range(-1, 1)
	
	rotate(randf()*PI)

func _process(delta):
	rotate(angular_velocity * delta * sign(rotation_dir))