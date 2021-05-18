extends ColorRect

func _draw():
	if (Gameplay.canvas != null):
		Gameplay.canvas.draw_solution(self, Gameplay.solution)
		Gameplay.canvas.draw_validation(self, Gameplay.puzzle, Gameplay.validator, Gameplay.validation_elasped_time)
