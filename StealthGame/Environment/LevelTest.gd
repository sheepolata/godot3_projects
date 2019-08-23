extends Node2D

onready var en1 = $Enemy

# Called when the node enters the scene tree for the first time.
func _ready():
	return
	en1.position = en1.waypoints.get_start_position()
		
	en1.target_position = en1.waypoints.get_next_point_position()
	en1.look_at(en1.target_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
