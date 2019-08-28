extends Node2D

onready var player = $Player
onready var asteroid_node = $Asteroids
onready var ast_timer = $Asteroids/Spawner

export(int) var max_nb_asteroid : int = 1
export(Vector2) var asteroid_freq_limits = Vector2(2.0, 4.0)

# Called when the node enters the scene tree for the first time.
func _ready():
	ast_timer.wait_time = rand_range(asteroid_freq_limits.x, asteroid_freq_limits.y)
	ast_timer.start()

func _process(delta):
	pass
	
func spaw_asteroid():
	if asteroid_node.get_child_count() < (max_nb_asteroid + 1):
		print("SPAWN ONE")
		var ast = preload("res://Environments/Asteroid.tscn").instance()
		
		asteroid_node.add_child(ast)
		
		#set position
		var r = 2048
		var a = randf() * PI * 2
		ast.position = Vector2(player.position.x + r * cos(a), player.position.y + r * sin(a))
		
		#set fly_direction
		ast.fly_direction = player.position
	
	ast_timer.wait_time = rand_range(asteroid_freq_limits.x, asteroid_freq_limits.y)