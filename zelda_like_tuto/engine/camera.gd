extends Camera2D

const screen_size = Vector2(160, 128)
const hud_thickness = 16
var grid_pos = Vector2(0, 0)

onready var previous_position = global_position
onready var previous_grid_pos = grid_pos

onready var tween = $Tween

func _ready():
	pass
	
func _process(delta):
	var player_grid_pos = get_grid_pos(get_node("../player").global_position)
	
	if player_grid_pos != grid_pos:
		print("change cam pos")
		
		previous_position = global_position
		previous_grid_pos = grid_pos
		
		#global_position = player_grid_pos * screen_size
		tween.interpolate_property(self, "global_position", global_position, player_grid_pos*screen_size, 0.4, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
		
		$StaticBody2D/top.disabled = true
		$StaticBody2D/bottom.disabled = true
		$StaticBody2D/left.disabled = true
		$StaticBody2D/right.disabled = true
		
		
		grid_pos = player_grid_pos
	
	
func get_grid_pos(pos):
	pos.y -= hud_thickness
	var x = floor(pos.x / screen_size.x)
	var y = floor(pos.y / screen_size.y)
	return Vector2(x, y)

func get_enemies():
	var enemies = []
	for body in $area.get_overlapping_bodies():
		if body.get("type") == "enemy" and enemies.find(body) == -1:
			enemies.append(body)
	return enemies.size()

func _on_area_body_entered(body):
	if body.get("type") == "enemy":
		body.set_physics_process(true)


func _on_area_body_exited(body):
	if body.get("type") == "enemy":
		body.set_physics_process(false)


func _on_area_area_exited(area):
	if area.get("disappears") == true:
		area.queue_free()


func _on_Tween_tween_completed(object, key):
	$StaticBody2D/top.disabled = false
	$StaticBody2D/bottom.disabled = false
	$StaticBody2D/left.disabled = false
	$StaticBody2D/right.disabled = false
