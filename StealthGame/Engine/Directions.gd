tool
extends Node

const center 	= Vector2(0,0)
const left		= Vector2(-1,0)
const right		= Vector2(1,0)
const up		= Vector2(0,-1)
const down		= Vector2(0,1)

func rand():
	var d = randi() % 4 + 1
	match d:
		1:
			return left
		2:
			return right
		3:
			return up
		4:
			return down

func point_from_angle_rad(origin : Vector2, angle : float, distance : float) -> Vector2:
	return Vector2(origin.x + distance * cos(angle), origin.y + distance * sin(angle))
	
func get_direction_vector(node : Node2D) -> Vector2:
	return Vector2(cos(node.rotation), sin(node.rotation)).normalized()
	
func get_direction_angle(angle : float) -> Vector2:
	return Vector2(cos(angle), sin(angle)).normalized()