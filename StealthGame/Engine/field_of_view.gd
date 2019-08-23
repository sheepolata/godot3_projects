extends Node

class_name FieldOfView

export(float, 0, 3000) var view_radius : float = 150.0
export(float, 0, 360) var view_angle : float = 120.0
export(float, 0, 1) var mesh_resolution : float = 0.1



func find_visible_targets() -> void:
	pass


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
