extends Node
const graph = preload("res://script/graph.gd")

class Solution:
	var started: bool
	var start_pos: Vector2
	var start_vertex
	var segments: Array
	
	func get_head():
		if (not started):
			return null
		if (len(segments) == 0):
			return start_pos
		var last_segment = segments[-1]
		
	func try_start_solution_at(puzzle, pos):
		if (started):
			started = false
			return false
		for vertex in puzzle.vertices:
			if (vertex.decorator.rule == 'start'):
				if ((pos - vertex.pos).length() < puzzle.start_size):
					started = true
					start_pos = vertex.pos
					start_vertex = vertex
					segments = []
					return true
		return false
				
	func det(v1, v2):
		return v1.x * v2.y - v2.x * v1.y
		
	func get_end_position():
		if (!started):
			return null
		if (len(segments) == 0):
			return start_pos
		var segment = segments[-1]
		var edge = segment[0]
		var percentage = segment[2]
		if (segment[1]):
			percentage = 1.0 - percentage
		var pos = edge.start.pos * (1.0 - percentage) + edge.end.pos * percentage
		return pos

	func try_continue_solution(puzzle, delta):
		if (!started):
			return
		if (delta.length() < 1e-6):
			return
		var crossroad_vertex = null
		var previous_edge = null
		if (len(segments) == 0):
			crossroad_vertex = start_vertex
		elif (segments[-1][2] >= 1.0):
			previous_edge = segments[-1][0]
			if (segments[-1][1]):
				crossroad_vertex = previous_edge.start
			else:
				crossroad_vertex = previous_edge.end
		if (crossroad_vertex != null):
			var chosen_edge = null
			var best_aligned_score = 0.0
			for edge in puzzle.edges:
				var end_to_start
				if (edge.start == crossroad_vertex):
					end_to_start = false
				elif (edge.end == crossroad_vertex):
					end_to_start = true
				else:
					continue
				var backtrace_path = edge == previous_edge
				var aligned_score = (edge.end.pos - edge.start.pos).normalized().dot(delta)
				if (end_to_start):
					aligned_score = -aligned_score
				if (aligned_score > best_aligned_score):
					chosen_edge = [edge, end_to_start, backtrace_path]
			if (chosen_edge != null):
				if (chosen_edge[2]): # backtrace
					segments[-1][2] = 1.0 - 1e-6
				else:
					segments.append([chosen_edge[0], chosen_edge[1], 1e-6])
			else:
				return
		if(len(segments) > 0):
			var edge = segments[-1][0]
			var end_to_start =segments[-1][1]
			var last_percentage = segments[-1][2]
			var edge_vec = edge.end.pos - edge.start.pos
			var edge_length = edge_vec.length()
			var projected_length = edge_vec.normalized().dot(delta) / edge_length
			var projected_det = abs(det(edge_vec.normalized(), delta)) / edge_length
			if (end_to_start):
				projected_length = -projected_length
			var projected_percentage = last_percentage + projected_length
			var end_node = edge.start if end_to_start else edge.end
			var limit = 1.0 + 1e-6
			if (end_node == start_vertex):
				limit = 1.0 - (puzzle.start_size + puzzle.line_width / 2) / edge_length
			else:
				for i in range(len(segments) - 1):
					if (segments[i][0].start == end_node or 
						segments[i][0].end == end_node):
						limit = 1.0 - puzzle.line_width / edge_length
						break
			if (end_to_start): # second half is always end to start
				projected_percentage += projected_det * 0.5 # encourage
			else:
				projected_percentage -= projected_det * 0.5 # discorage
			if (projected_percentage <= 0.0):
				segments.pop_back()
				return
			if (projected_percentage >= limit):
				projected_percentage = limit
			segments[-1][2] = projected_percentage
	
		
		
