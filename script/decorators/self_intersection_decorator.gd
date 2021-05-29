extends "../decorator.gd"

var rule = 'self-intersection'
var color1: Color
var color2: Color

func draw_shape(canvas, puzzle, color):
	var radius = 0.45 * puzzle.line_width
	var space = 0.02
	var dirs = [
		Vector2(1, 0),
		Vector2(cos(PI / 3), sin(PI / 3)),
		Vector2(cos(2 * PI / 3), sin(2 * PI / 3))
	]
	canvas.add_polygon([
		radius * dirs[1] - space * dirs[0],
		radius * dirs[2],
		-radius * dirs[0],
		-radius * dirs[1] + space * dirs[2]
	], color1)
	canvas.add_polygon([
		-radius * dirs[1] + space * dirs[0],
		-radius * dirs[2],
		radius * dirs[0],
		radius * dirs[1] - space * dirs[2]
	], color2)

func draw_foreground(canvas: Visualizer.PuzzleCanvas, owner, owner_type: int, puzzle: Graph.Puzzle):
	draw_shape(canvas, puzzle, color)
	
func draw_above_solution(canvas, owner, owner_type, puzzle, solution):
	draw_shape(canvas, puzzle, color) 
