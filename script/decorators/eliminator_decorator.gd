extends "../decorator.gd"

var rule = 'eliminator'
const END_DIRECTIONS = [Vector2(0.0, -1.0), Vector2(-0.8660254, 0.5), Vector2(0.8660254, 0.5)]
		
func draw_foreground(canvas: Visualizer.PuzzleCanvas, owner, owner_type: int, puzzle: Graph.Puzzle):
	if (owner_type == Graph.FACET_ELEMENT):
		var eliminatorLength = 0.200 * (1 - puzzle.line_width)
		var thickness = 0.115 * (1 - puzzle.line_width)
		for direction in END_DIRECTIONS:
			canvas.add_line(owner.center, owner.center + direction * eliminatorLength, thickness, color)

