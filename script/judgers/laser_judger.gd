extends Node
const TARGET_SIZE = 0.1

func laser_pass_point(validator: Validation.Validator, pos: Vector2, color: Color):
	var puzzle = validator.puzzle
	var passed_laser_colors = []
	for i in range(len(puzzle.decorators)):
		if (puzzle.decorators[i].rule == 'laser-manager'):
			var lasers = validator.solution.event_properties[i]
			for k in range(len(lasers)):
				var laser = lasers[k]
				for j in range(len(laser) - 1):
					if (Geometry.segment_intersects_circle(laser[j], laser[j + 1], pos, TARGET_SIZE) >= 0):
						passed_laser_colors.append(puzzle.decorators[i].laser_colors[k])
						break
		if (len(passed_laser_colors) == 0):
			return false
		if (color == Color.black):
			return true # black matches everything
		var color_comp = [0, 0, 0]
		for laser_color in passed_laser_colors:
			color_comp[0] = max(color_comp[0], laser_color.r)
			color_comp[1] = max(color_comp[1], laser_color.g)
			color_comp[2] = max(color_comp[2], laser_color.b)
		return abs(color_comp[0] - color.r) <= 1e-2 and abs(color_comp[1] - color.g) <= 1e-2 and abs(color_comp[2] - color.b) <= 1e-2
	return false
