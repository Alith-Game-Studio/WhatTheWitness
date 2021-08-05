extends Control

func _draw():
	if (Gameplay.background_texture != null):
		if (Gameplay.canvas != null):
			Gameplay.canvas.draw_additive_layer(self, Gameplay.solution, Gameplay.validator, Gameplay.validation_elasped_time)
