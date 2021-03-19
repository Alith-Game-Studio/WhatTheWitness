extends ColorRect

func _draw():
	if (Gameplay.canvas != null):
		Gameplay.canvas.draw_puzzle(self)
