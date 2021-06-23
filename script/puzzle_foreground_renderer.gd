extends Control

func _draw():
	if (Gameplay.background_texture != null):
		draw_texture(Gameplay.background_texture, Vector2(0, 0))
		if (Gameplay.canvas != null):
			Gameplay.canvas.draw_solution(self, Gameplay.solution, Gameplay.validator, Gameplay.validation_elasped_time)
			Gameplay.canvas.draw_validation(self, Gameplay.puzzle, Gameplay.validator, Gameplay.validation_elasped_time)
