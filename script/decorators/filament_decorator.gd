extends "../decorator.gd"

var rule = 'filament-pillar'
var circleRadius = 0.08
var center: Vector2

var filament_start_decorator
var valid: bool = false

func draw_foreground(canvas: Visualizer.PuzzleCanvas, owner, owner_type: int, puzzle: Graph.Puzzle):
	canvas.add_circle(Vector2.ZERO, circleRadius, color)
		
func calculate_validity():
	var filament_solution = filament_start_decorator.filament_solution
	if (filament_solution == null):
		valid = false
	else:
		valid = false
		var filament_solution_length = len(filament_solution.path_points)
		for i in range(filament_solution_length):
			var end_pos = filament_solution.end_pos if i + 1 == filament_solution_length else filament_solution.path_points[i + 1][0]
			var start_pos = filament_solution.path_points[i][0]
			if (0 <= Geometry.segment_intersects_circle(start_pos, end_pos, center, circleRadius + 1e-2)):
				valid = true
				break
