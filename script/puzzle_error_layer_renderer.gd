extends Control

func _draw():
	if (Gameplay.background_texture != null):
		if (Gameplay.canvas != null):
			var error_transparency = Gameplay.canvas.draw_validation(self, Gameplay.puzzle, Gameplay.validator, Gameplay.validation_elasped_time, true)
			if (error_transparency != null):
				self.modulate = Color(1.0, 1.0, 1.0, error_transparency)
