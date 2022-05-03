extends Control

func _draw():
	var canvas = Visualizer.PuzzleCanvas.new()
	var puzzle_name = name.replace('|', '.')
	var puzzle_path = 'res://puzzles/%s' % puzzle_name
	var puzzle = Graph.load_from_xml(puzzle_path, true)
	canvas.puzzle = puzzle
	var size = self.get_rect().size
	canvas.normalize_view(size)
	canvas.drawing_target = self
	draw_line(Vector2(0, size.y / 2), Vector2(size.x, size.y / 2), Color(0, 0.2, 0.6), size.y)
	if (puzzle_name in SaveData.saved_solutions):
		var solution = Solution.SolutionLine.load_from_string(SaveData.saved_solutions[puzzle_name], puzzle)
		canvas.draw_solution_line(self, solution, Color(1, 1, 1), 2.0)

