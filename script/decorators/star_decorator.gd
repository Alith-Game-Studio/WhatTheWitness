extends "../decorator.gd"

var rule = 'star'

func draw_foreground(canvas, owner, owner_type, puzzle, solution):
	var distance = 0.194 * (1 - puzzle.line_width)
	var skewDistance = distance * 0.7071068
	var width = distance * 2
	if (owner_type == 2):
		canvas.add_line(
			owner.center - Vector2(distance, 0), 
			owner.center + Vector2(distance, 0), 
			width, 
			color
		)
		canvas.add_line(
			owner.center + Vector2(skewDistance, -skewDistance), 
			owner.center + Vector2(-skewDistance, skewDistance), 
			width, 
			color
		)
