extends Node2D

onready var player = $Player
onready var asteroid_node = $Asteroids
onready var ast_timer = $Asteroids/Spawner

export(int) var max_nb_asteroid : int = 8
export(Vector2) var asteroid_freq_limits = Vector2(2.0, 4.0)

export(int) var random_target_offset_range = 512

export(int) var asteroid_spawn_radius = 2048

var nb_stations_killed : int setget set_nb_stations_killed
export(int) var station_spawn_radius = 4096

var time : float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	add_to_group("world")
	
	self.nb_stations_killed = -1
	
	ast_timer.wait_time = rand_range(asteroid_freq_limits.x, asteroid_freq_limits.y)
	ast_timer.start()
	
	$DifficultyUpper.start()
	
#	$ParallaxBackground.scale = Vector2(player.max_zoom_out, player.max_zoom_out)

func _process(delta):
	time += delta
	$UIWorldLayer/TimeLab.text = "%10.1f"%stepify(time, 0.1)
	
	
	if $Stations.get_child_count() == 0 or $Stations.get_children()[0].is_dead:
		self.nb_stations_killed += 1
		spawn_station()
		if self.nb_stations_killed > 0:
			up_difficulty()
	else:
		$UIWorldLayer/StationDirection.rect_rotation = rad2deg(player.position.angle_to_point($Stations.get_children()[0].position)) - 90
	
	for asteroid in asteroid_node.get_children():
		if "asteroid" in asteroid.get_groups():
			if player.position.distance_to(asteroid.position) > asteroid_spawn_radius*2:
				asteroid.queue_free()
	
func spaw_asteroid():
	if asteroid_node.get_child_count() < (max_nb_asteroid + 1):

		var ast = preload("res://Environments/Objects/Asteroid.tscn").instance()
		
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

func spawn_station():
	var st = preload("res://Characters/Enemies/Station.tscn").instance()
	$Stations.add_child(st)
	
	var a = randf() * PI * 2
	st.position = Vector2(player.position.x + station_spawn_radius * cos(a), 
								player.position.y + station_spawn_radius * sin(a))

func up_difficulty():
	var rnd = randf()
	print(rnd)
	if rnd < 0.15:
		var string = str(max_nb_asteroid) + " to "
		max_nb_asteroid = int(max_nb_asteroid * 1.5)
		string += str(max_nb_asteroid)
		print(string)
	elif rnd >= .15 and rnd < 0.15+0.35:
		var string = str(max_nb_asteroid) + " to "
		max_nb_asteroid += 2
		string += str(max_nb_asteroid) + ", " + str(asteroid_freq_limits) + " to "
		asteroid_freq_limits = Vector2(
							max(.15, asteroid_freq_limits.x*.95), 
							max(.3, asteroid_freq_limits.y*.95)
						)
		string += str(asteroid_freq_limits)
		print(string)
	else:
		var string = str(asteroid_freq_limits) + " to "
		asteroid_freq_limits = Vector2(
							max(.15, asteroid_freq_limits.x*.9), 
							max(.3, asteroid_freq_limits.y*.9)
						)
		string += str(asteroid_freq_limits)
		print(string)
		
func set_nb_stations_killed(value : int):
#	print("HEY")
	nb_stations_killed = value
	$UIWorldLayer/KillsLab.text = "Kills: %3d" % [nb_stations_killed]

func _on_DifficultyUpper_timeout():
	up_difficulty()
	$DifficultyUpper.start()























