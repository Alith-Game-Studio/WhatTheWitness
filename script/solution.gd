extends Node

class SolutionLine:
	var started: bool
	var start_vertices: Array
	var lines: Array
	var progress: Array
	var validity = 0
	const MAIN_WAY = 0
	
	func get_symmetry_point(puzzle, way, pos):
		if (way == 0):
			return pos
		if (puzzle.symmetry_type == Graph.SYMMETRY_ROTATIONAL):
			return (pos - puzzle.symmetry_center).rotated(2 * PI * way / puzzle.n_ways) + puzzle.symmetry_center
		
	func get_symmetry_vector(puzzle, way, vec):
		if (way == 0):
			return vec
		if (puzzle.symmetry_type == Graph.SYMMETRY_ROTATIONAL):
			return vec.rotated(2 * PI * way / puzzle.n_ways)
		
	
	func get_nearest_start(puzzle, pos):
		var best_dist = puzzle.start_size
		var result = null
		for vertex in puzzle.vertices:
			if (vertex.decorator.rule == 'start'):
				var dist = (pos - vertex.pos).length()
				if (dist < best_dist):
					result = vertex
					best_dist = dist
		return result
		
		
	func try_start_solution_at(puzzle, pos):
		validity = 0
		var est_start_vertex = get_nearest_start(puzzle, pos)
		if (est_start_vertex == null):
			return false
		var new_start_vertices = []
		var new_lines = []
		for way in range(puzzle.n_ways):
			var est_way_start_pos = get_symmetry_point(puzzle, way, est_start_vertex.pos)
			var way_start_vertex = get_nearest_start(puzzle, est_way_start_pos)
			if (way_start_vertex == null):
				return false
			new_start_vertices.push_back(way_start_vertex)
			new_lines.push_back([])
		start_vertices = new_start_vertices
		lines = new_lines
		progress = []
		started = true
		return true
				
	func det(v1, v2):
		return v1.x * v2.y - v2.x * v1.y
		
	func get_end_position(way):
		if (!started):
			return null
		if (len(lines[way]) == 0):
			return start_vertices[way].pos
		var segment = lines[way][-1]
		var edge = segment[0]
		var percentage = progress[-1]
		if (segment[1]):
			percentage = 1.0 - percentage
		var pos = edge.start.pos * (1.0 - percentage) + edge.end.pos * percentage
		return pos
		
	func __get_crossroad(way):
		var crossroad_vertex = null
		var previous_edge = null
		if (len(lines[way]) == 0): # line is just started
			crossroad_vertex = start_vertices[way]
		elif (progress[-1] >= 1.0): # all lines are at cross road
			previous_edge = lines[way][-1][0]
			if (lines[way][-1][1]): # the last segment is a backward edge
				crossroad_vertex = previous_edge.start
			else:
				crossroad_vertex = previous_edge.end
		return [crossroad_vertex, previous_edge]
		
	func is_completed():
		if (!started):
			return false
		var crossroad_vertex = null
		var previous_edge = null
		if (len(lines[MAIN_WAY]) == 0): # line is just started
			return false
		elif (progress[-1] >= 1.0):
			previous_edge = lines[MAIN_WAY][-1][0]
			if (lines[MAIN_WAY][-1][1]): # the last segment is a backward edge
				return previous_edge.start.decorator != null and previous_edge.start.decorator.rule == 'end'
			else:
				return previous_edge.end.decorator != null and previous_edge.end.decorator.rule == 'end'
		return false
			
		
	func get_total_length():
		if (!started):
			return 0.0
		var result = 0.0
		for i in range(len(progress)):
			var edge = lines[MAIN_WAY][i][0]
			result += progress[i] * (edge.start.pos - edge.end.pos).length()
		return result
		
	func __try_introduce_segment_at(puzzle, dir, init_progress=1e-6):
		var result = []
		for way in range(puzzle.n_ways):
			var way_dir = get_symmetry_vector(puzzle, way, dir)
			# print('Finding %d' % way, way_dir)
			var tuple = __get_crossroad(way)
			var crossroad_vertex = tuple[0]
			var previous_edge = tuple[1]
			if (crossroad_vertex == null):
				return false
			var ok = false
			for edge in puzzle.edges:
				if (edge == previous_edge):
					continue
				var end_to_start
				var edge_dir
				if (edge.start == crossroad_vertex):
					end_to_start = false
					edge_dir = (edge.end.pos - edge.start.pos).normalized()
				elif (edge.end == crossroad_vertex):
					end_to_start = true
					edge_dir = (edge.start.pos - edge.end.pos).normalized()
				else:
					continue
				# print((edge_dir - way_dir).length())
				if ((edge_dir - way_dir).length() < 1e-6):
					result.append([edge, end_to_start])
					# print('Found!')
					ok = true
					break
			if (!ok):
				return false
		for way in range(puzzle.n_ways):
			lines[way].append(result[way])
		progress.append(init_progress)
		return true
		
	func __calc_way_limit(puzzle, way, main_edge_length):
		var limit = 1.0 + 1e-6
		var edge = lines[way][-1][0]
		var edge_vec = edge.end.pos - edge.start.pos
		var edge_length = edge_vec.length()
		var end_to_start = lines[way][-1][1]
		var end_node = edge.start if end_to_start else edge.end
		
		# different length from the main line (asymmetrical edges)
		if (abs(edge_length - main_edge_length) > 1e-2):
			limit = min(limit, 1.0 - 1e-6)
			if (edge_length < main_edge_length):
				limit = min(limit, 1.0 * edge_length / main_edge_length)
		
		# colliding with starts
		for start_vertex in start_vertices:
			if (end_node == start_vertex):
				limit = min(limit, 1.0 - (puzzle.start_size + puzzle.line_width / 2) / main_edge_length)
		
		# colliding with other lines (or self-colliding)
		if (end_node.decorator.rule != 'self-intersection'):
			for way_2 in range(puzzle.n_ways):
				for i in range(len(lines[way_2]) - 1):
					if (lines[way_2][i][0].start == end_node or 
						lines[way_2][i][0].end == end_node):
						limit = min(limit, 1.0 - puzzle.line_width / edge_length)
						return limit
		return limit
	
	func __dynamic_obstacle_collide(puzzle, way, solution_length):
		var end_pos = get_end_position(way)
		for decorator in puzzle.decorators:
			if (decorator.rule == 'obstacle'):
				if (decorator.collide_test(end_pos, solution_length)):
					return true
		return false
		
	func try_continue_solution(puzzle, delta):
		if (!started):
			return
		if (delta.length() < 1e-6):
			return
		var tuple = __get_crossroad(MAIN_WAY)
		var crossroad_vertex = tuple[0]
		var previous_edge = tuple[1]
		if (crossroad_vertex != null):
			var chosen_edge = null
			var best_aligned_score = 0.0
			for edge in puzzle.edges:
				var end_to_start
				var edge_dir
				if (edge.start == crossroad_vertex):
					end_to_start = false
					edge_dir = (edge.end.pos - edge.start.pos).normalized()
				elif (edge.end == crossroad_vertex):
					end_to_start = true
					edge_dir = (edge.start.pos - edge.end.pos).normalized()
				else:
					continue
				var backtrace_path = edge == previous_edge
				var aligned_score = edge_dir.dot(delta)
				if (aligned_score > best_aligned_score):
					chosen_edge = [edge, end_to_start, backtrace_path, edge_dir]
			if (chosen_edge != null):
				if (crossroad_vertex.decorator.rule == 'self-intersection'):
					# additional check: no overlapping edges
					for way_2 in range(puzzle.n_ways):
						for i in range(len(lines[way_2]) - 1):
							if (lines[way_2][i][0] == chosen_edge[0]):
								return
				if (chosen_edge[2]): # backtrace, no extra check
					progress[-1] = 1.0 - 1e-6
				else:
					# introducing new segment, some extra checks apply here
					# todo: extra multiline conditions
					if(!__try_introduce_segment_at(puzzle, chosen_edge[3])):
						return
			else:
				return
		if(len(lines[MAIN_WAY]) > 0):
			var edge = lines[MAIN_WAY][-1][0]
			var end_to_start = lines[MAIN_WAY][-1][1]
			var last_progress = progress[-1]
			var edge_vec = edge.end.pos - edge.start.pos
			var edge_length = edge_vec.length()
			
			# calculate upper limit (lower limit is always 0)
			var limit = 1.0 + 1e-6
			for way in range(puzzle.n_ways):
				limit = min(limit, __calc_way_limit(puzzle, way, edge_length))
				
			# calculate new progress
			var projected_length = edge_vec.normalized().dot(delta) / edge_length
			var projected_det = abs(det(edge_vec.normalized(), delta)) / edge_length
			if (end_to_start):
				projected_length = -projected_length
			var projected_progress = last_progress + projected_length
			if ((!edge.end_is_crossroad and end_to_start) or (edge.end_is_crossroad and last_progress > 0.5)): # second half is always end to start
				projected_progress += projected_det * 0.5 # encourage
			else:
				projected_progress -= projected_det * 0.5 # discorage
			if (projected_progress <= 0.0):
				for way in range(puzzle.n_ways):
					lines[way].pop_back()
				progress.pop_back()
				return
			if (projected_progress >= limit):
				projected_progress = limit
			var temp = progress[-1]
			progress[-1] = projected_progress
			var solution_length = get_total_length()
			for way in range(puzzle.n_ways):
				if (__dynamic_obstacle_collide(puzzle, way, solution_length)):
					progress[-1] = temp
					return
	
		
		
