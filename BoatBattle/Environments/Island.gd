extends StaticBody2D


func _ready():
	add_to_group("island")
	
	randomize()
	rotate(randf()*PI)