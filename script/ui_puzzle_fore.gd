extends ColorRect

func _draw():
	if (Gameplay.solver_canvas != null):
		Gameplay.solver_canvas.draw_witness()
