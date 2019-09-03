extends Sprite

export(float) var duration : float = 0.5
export(float) var max_scale : float = 7.0;
export var min_scale : float = 0 setget set_min_scale; 

onready var tween = $Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	scale = Vector2(min_scale, min_scale)
	tween.interpolate_property(self, "scale", Vector2(min_scale, min_scale), Vector2(max_scale, max_scale), duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	
func set_max_scale(value):
	max_scale = value
	#tween.interpolate_property(self, "scale", Vector2(min_scale, min_scale), Vector2(max_scale, max_scale), duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	#tween.start()
	
func set_min_scale(value):
	min_scale = value
	#tween.interpolate_property(self, "scale", Vector2(min_scale, min_scale), Vector2(max_scale, max_scale), duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	#tween.start()
	
func _on_Tween_tween_all_completed():
	queue_free()
