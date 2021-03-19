extends "../decorator.gd"

var rule = 'triangle'

var count

func draw_foreground(canvas: Visualizer.PuzzleCanvas, owner, owner_type: int, puzzle: Graph.Puzzle):
	if (owner_type == 2):
		var length = 0.2 * (1 - puzzle.line_width)
		var distance = 0.05 * (1 - puzzle.line_width)
		var height = 0.175 * (1 - puzzle.line_width)
		var levels = (count - 1) / 3 + 1;
		var numbersPerlevel = []
		var left = count
		for i in range(levels):
			numbersPerlevel.push_back(left if left <= 3 else 2 if left == 4 else 3)
			left -= numbersPerlevel[i]
			
		var totalHeight = height * levels + distance * (levels - 1)
		var currentHeight = totalHeight / 2
		for level in range(levels):
			var totalWidth = length * numbersPerlevel[level] + distance * (numbersPerlevel[level] - 1)
			var p1 = Vector2(-totalWidth / 2, currentHeight)
			var p2 = Vector2(-totalWidth / 2 + length / 2, currentHeight - height)
			var p3 = Vector2(-totalWidth / 2 + length, currentHeight)
			for i in range(numbersPerlevel[level]):
				canvas.add_polygon([
					p1 + owner.center,
					p2 + owner.center,
					p3 + owner.center
				], color)
				p1 += Vector2(length + distance, 0)
				p2 += Vector2(length + distance, 0)
				p3 += Vector2(length + distance, 0)
			currentHeight -= height + distance;
		
