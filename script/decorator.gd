extends Node

var color = null
var angle: float = 0.0
var additional_scale: float = 1.0


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
