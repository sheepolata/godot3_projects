extends StaticBody2D

func _on_area_body_entered(body):
	if body.name == "player" and body.keys > 0:
		body.keys -= 1
		queue_free()
