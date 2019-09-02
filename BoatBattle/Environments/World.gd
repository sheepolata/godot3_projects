extends Node2D

onready var player = $Player
onready var asteroid_node = $Asteroids
onready var ast_timer = $Asteroids/Spawner

export(int) var max_nb_asteroid : int = 1
export(Vector2) var asteroid_freq_limits = Vector2(2.0, 4.0)

export(int) var random_target_offset_range = 512

export(int) var asteroid_spawn_radius = 2048

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	ast_timer.wait_time = rand_range(asteroid_freq_limits.x, asteroid_freq_limits.y)
	ast_timer.start()
	
#	$ParallaxBackground.scale = Vector2(player.max_zoom_out, player.max_zoom_out)

func _process(delta):
	
	for asteroid in asteroid_node.get_children():
		if "asteroid" in asteroid.get_groups():
			if player.position.distance_to(asteroid.position) > asteroid_spawn_radius*2:
				asteroid.queue_free()
	
func spaw_asteroid():
	if asteroid_node.get_child_count() < (max_nb_asteroid + 1):

		var ast = preload("res://Environments/Asteroid.tscn").instance()
		
		asteroid_node.add_child(ast)
		
		#set position
		var a = randf() * PI * 2
		var random_target_offset = Vector2(
										rand_range(-(random_target_offset_range/2), (random_target_offset_range/2)),
										rand_range(-(random_target_offset_range/2), (random_target_offset_range/2))
										)
		
		ast.position = Vector2(player.position.x + asteroid_spawn_radius * cos(a), 
								player.position.y + asteroid_spawn_radius * sin(a))
		
		#set fly_direction
		ast.fly_direction = player.position + random_target_offset
	
	ast_timer.wait_time = rand_range(asteroid_freq_limits.x, asteroid_freq_limits.y)