extends "../decorator.gd"

var rule = 'limited_water'
const texture = preload("res://img/infinite_water.png")

func draw_above_solution(canvas, owner, owner_type, puzzle, solution):
	var size = puzzle.start_size * 1.5
	canvas.add_texture(Vector2.ZERO, Vector2(size, size), texture, color)
