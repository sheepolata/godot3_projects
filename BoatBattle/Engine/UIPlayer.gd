extends CanvasLayer

signal ScoreAddDisplay_timeout(_timer)

func _on_ScoreAddDisplay_timeout():
	emit_signal("ScoreAddDisplay_timeout", $ScoreAdd/ScoreAddDisplay)
