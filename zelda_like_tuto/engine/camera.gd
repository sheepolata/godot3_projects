extends Camera2D

func _ready():
	pass
	
func _process(delta):
	var pos = get_node("../player").global_position - Vector2(0, 16)
	var x	= floor(pos.x / 160) * 160
	var y	= floor(pos.y / 128) * 128
	global_position = Vector2(x, y)
	

func _on_area_body_entered(body):
	if body.get("type") == "enemy":
		body.set_physics_process(true)


func _on_area_body_exited(body):
	if body.get("type") == "enemy":
		body.set_physics_process(false)
