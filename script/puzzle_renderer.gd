extends Control

func _draw():
	var canvas = Visualizer.PuzzleCanvas.new()
	var puzzle_name = name.replace('|', '.')
	var puzzle_path = 'res://puzzles/%s' % puzzle_name
	var puzzle = Graph.load_from_xml(puzzle_path, true)
	canvas.puzzle = puzzle
	canvas.normalize_view(self.get_rect().size)
	canvas.draw_puzzle(self)
	if (puzzle_name in SaveData.saved_solutions):
		var solution = Solution.SolutionLine.load_from_string(SaveData.saved_solutions[puzzle_name], puzzle)
		canvas.draw_solution(self, solution, null, 10.0)
	else:
		canvas.draw_solution(self, null, null, 10.0)

