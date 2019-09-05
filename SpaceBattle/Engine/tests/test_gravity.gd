extends Node2D

var G = 4000.0
var body = {position = Vector2(200, 100)*2, velocity = Vector2(0, 1)}
var center = Vector2(512*2, 400*2)

func _ready():
	set_process(true)
	
func acceleration(pos1 : Vector2, pos2 : Vector2) -> Vector2:
	var direction : Vector2 = pos1 - pos2
	var length : float = sqrt(direction.x*direction.x + direction.y*direction.y)
	var normal : Vector2 = direction / length
	return normal*(G/pow(length, 2))
	
func step_euler(center, body):
	var step = 8
	for i in range(step):
		var dt = 1.0/step
		var acc = acceleration(center, body.position)
		body.velocity = body.velocity + acc*dt
		body.position = body.position + body.velocity*dt
	
func _process(delta):
	update()
	step_euler(center, body)
	
func _draw():
	draw_circle(Vector2(200, 100)*2, 4, Color(0,0,1))
	draw_circle(body.position, 4, Color(0, 1, 0.7))
	draw_circle(center, 7, Color(1, 0.7, 0))
