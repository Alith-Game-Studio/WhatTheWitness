extends Control

func _draw():
	var canvas = Visualizer.PuzzleCanvas.new()
	var puzzle_path = 'res://puzzles/%s' % name.replace('|', '.')
	var puzzle = Graph.load_from_xml(puzzle_path)
	canvas.puzzle = puzzle
	canvas.normalize_view(self.get_rect().size)
	canvas.draw_puzzle(self)

