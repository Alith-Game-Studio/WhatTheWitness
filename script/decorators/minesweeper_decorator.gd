extends "../decorator.gd"

var rule = 'minesweeper'

var count

const textures = [
	preload("res://img/minesweeper/0.png"),
	preload("res://img/minesweeper/1.png"),
	preload("res://img/minesweeper/2.png"),
	preload("res://img/minesweeper/3.png"),
	preload("res://img/minesweeper/4.png"),
	preload("res://img/minesweeper/5.png"),
	preload("res://img/minesweeper/6.png"),
	preload("res://img/minesweeper/7.png"),
]

func draw_foreground(canvas: Visualizer.PuzzleCanvas, owner, owner_type: int, puzzle: Graph.Puzzle):
	var circleRadius = 0.35
	canvas.add_texture(Vector2.ZERO, Vector2(circleRadius * 2, circleRadius * 2), textures[count], color)
