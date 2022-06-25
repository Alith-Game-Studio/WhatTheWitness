extends "../decorator.gd"

var rule = 'point'

func draw_foreground(canvas: Visualizer.PuzzleCanvas, owner, owner_type: int, puzzle: Graph.Puzzle):
	var radius = 0.425 * puzzle.line_width
	var points = []
	for i in range(6):
		var angle = PI / 3 * i
		points.append(Vector2(cos(angle) * radius, sin(angle) * radius))
	canvas.add_polygon(points, color)
	
func draw_below_solution(canvas, owner, owner_type, puzzle, solution):
	return draw_foreground(canvas, owner, owner_type, puzzle)

func draw_question_mark(canvas, owner, owner_type: int, puzzle: Graph.Puzzle):
	return draw_foreground(canvas, owner, owner_type, puzzle)
