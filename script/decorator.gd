extends Node

var color = null
var angle: float = 0.0
var additional_scale: float = 1.0
const question_mark_texture = preload("res://img/question_mark.png")


func draw_foreground(canvas, owner, owner_type: int, puzzle: Graph.Puzzle):
	pass
	
func draw_below_solution(canvas, owner, owner_type, puzzle, solution):
	pass
	
func draw_above_solution(canvas, owner, owner_type, puzzle, solution):
	pass
	
func draw_additive_layer(canvas, owner, owner_type, puzzle, solution):
	pass
	
func post_load_state(puzzle, solution_state):
	pass

func draw_question_mark(canvas, owner, owner_type: int, puzzle: Graph.Puzzle):
	var draw_color = Color.black if color == null else color
	var size = 1.0 * (1 - puzzle.line_width)
	canvas.add_texture(Vector2.ZERO, Vector2(size, size), question_mark_texture, draw_color)
	
