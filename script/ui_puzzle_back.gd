extends ColorRect

func _draw():
	if (Gameplay.puzzle_canvas != null):
		Gameplay.puzzle_canvas.draw_witness()
