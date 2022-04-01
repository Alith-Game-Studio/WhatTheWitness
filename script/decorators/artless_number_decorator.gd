extends "../decorator.gd"

var rule = 'artless-number'

var count

func draw_foreground(canvas: Visualizer.PuzzleCanvas, owner, owner_type: int, puzzle: Graph.Puzzle):
	var length = 0.2 * (1 - puzzle.line_width)
	var distance = 0.05 * (1 - puzzle.line_width)
	var height = 0.175 * (1 - puzzle.line_width)
	var count_per_line = 2 if count == 4 else 3 if count <= 9 else 4
	var levels = (count - 1) / count_per_line + 1;
	var numbersPerlevel = []
	var left = count
	for i in range(levels):
		numbersPerlevel.push_back(left if left <= count_per_line else count_per_line)
		left -= numbersPerlevel[i]
		
	var totalHeight = height * levels + distance * (levels - 1)
	var currentHeight = totalHeight / 2
	for level in range(levels):
		var totalWidth = length * numbersPerlevel[level] + distance * (numbersPerlevel[level] - 1)
		var p1 = Vector2(-totalWidth / 2, currentHeight)
		var p2 = Vector2(-totalWidth / 2 + length / 2, currentHeight - height)
		var p3 = Vector2(-totalWidth / 2 + length, currentHeight)
		for i in range(numbersPerlevel[level]):
			canvas.add_circle(
				(p1 + p2 + p3) / 3, length / 2, color)
			p1 += Vector2(length + distance, 0)
			p2 += Vector2(length + distance, 0)
			p3 += Vector2(length + distance, 0)
		currentHeight -= height + distance
	
