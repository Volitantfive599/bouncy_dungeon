extends CanvasLayer

func fade(disappearing):
	var tween = create_tween()
	if disappearing:
		tween.tween_property($ColorRect, "modulate:a", 1.0, 1.0)
	else:
		tween.tween_property($ColorRect, "modulate:a", 0.0, 1.0)
