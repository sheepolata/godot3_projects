extends "res://pickups/pickup.gd"


func body_entered(body):
	.body_entered(body)
	
	if body.name == "player" and body.get("keys") < 9:
		body.keys += 1
		queue_free()
