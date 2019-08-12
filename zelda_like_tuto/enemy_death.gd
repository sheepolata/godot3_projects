extends Node2D

func _ready():
	$anim.play("default")

func _on_anim_animation_finished(anim_name):
	queue_free()
