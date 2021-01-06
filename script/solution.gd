extends Node
var graph = preload("res://script/graph.gd").new()


class Solution:
	var started: bool
	var start_pos: Vector2
	var segments: Array
	
	func get_head():
		if (not started):
			return null
		if (len(segments) == 0):
			return start_pos
		var last_segment = segments[-1]
		
func try_start_solution_at(puzzle, pos):
	
