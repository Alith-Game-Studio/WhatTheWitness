extends Node

var saved_solutions = {}

func update(puzzle_name: String, solution_string: String):
	saved_solutions[puzzle_name] = solution_string
