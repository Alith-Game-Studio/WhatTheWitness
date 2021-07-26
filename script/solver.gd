extends Node

class Solver:
	var puzzle: Graph.Puzzle
	var s = preload("res://script/judgers/sugar.gd").new()
	var n_vertices: int
	var n_edges: int
	var vertice_neighbors: Array
	var edge_list: Array
	var solutions: Array
	var current_solution_id: int
	var is_solution: Array
	var is_start: Array
	var is_end: Array
	var solution_state: Solution.DiscreteSolutionState
	func solve(input_puzzle, max_solution_count):
		solution_state = Solution.DiscreteSolutionState.new()
		puzzle = input_puzzle
		n_vertices = len(puzzle.vertices)
		n_edges = len(puzzle.edges)
		print(puzzle)
		vertice_neighbors = []
		for v in range(n_vertices):
			vertice_neighbors.append([])
		for edge in puzzle.edges:
			vertice_neighbors[edge.start.index].append(edge.end.index)
			vertice_neighbors[edge.end.index].append(edge.start.index)
			edge_list.append([edge.start.index, edge.end.index])
		ensure_segment()
		solutions = s.solve(max_solution_count)
		return len(solutions) != 0
		
	func get_solution_count():
		return len(solutions)
		
	func to_solution_line():
		var sugar_solution = solutions[current_solution_id]
		var solution_line = Solution.SolutionLine.new()
		var solution_state = Solution.DiscreteSolutionState.new()
		var visited_vertices = {}
		for way in puzzle.n_ways:
			var way_vertices = []
			for v in range(n_vertices):
				if (sugar_solution[is_start[v]] == way):
					visited_vertices[v] = true
					way_vertices.append(v)
					var ok = true
					while(ok):
						ok = false
						for v2 in vertice_neighbors[v]:
							if (sugar_solution[is_solution[v2]] == way):
								if !(v2 in visited_vertices):
									visited_vertices[v2] = true
									way_vertices.append(v2)
									v = v2
									ok = true
									break
			solution_state.vertices.append(way_vertices)
		solution_line.state_stack.append(solution_state)
		solution_line.started = true
		solution_line.progress = 1.0
		return solution_line
				
	func ensure_segment():
		is_start = s.new_int_array(n_vertices, -1, puzzle.n_ways - 1, true)
		is_end = s.new_int_array(n_vertices, -1, puzzle.n_ways - 1)
		is_solution = s.new_int_array(n_vertices, -1, puzzle.n_ways - 1, true)
		for v in range(n_vertices):
			if (!puzzle.vertices[v].is_puzzle_start):
				s.ensure(s.eq(is_start[v], -1))
			if (!puzzle.vertices[v].is_puzzle_end):
				s.ensure(s.eq(is_end[v], -1))
		for way in range(puzzle.n_ways):
			s.ensure(s.imp(s.eq(is_start, way), s.eq(is_solution, way)))
			s.ensure(s.imp(s.eq(is_end, way), s.eq(is_solution, way)))
			var is_way_v_possible = {}
			for v in range(n_vertices):
				var connectivity_conditions = []
				for v2 in vertice_neighbors[v]:
					connectivity_conditions.append(s.eq(is_solution[v2], way))
				var degree = s.count_true(connectivity_conditions)
				var is_start_or_end = s.or_(s.eq(is_start[v], way), s.eq(is_end[v], way))
				s.ensure(s.imp(s.and_(s.eq(is_solution[v], way), s.not_(is_start_or_end)), s.eq(degree, '2')))
				s.ensure(s.imp(is_start_or_end, s.eq(degree, '1')))
				is_way_v_possible[v] = false
			if (way != Solution.MAIN_WAY):
				for v in range(n_vertices):
					var est_way_pos = solution_state.get_symmetry_point(puzzle, way, puzzle.vertices[v].pos)
					var vertex_way = puzzle.get_vertex_at(est_way_pos)
					if (vertex_way == null):
						s.ensure(s.neq(is_solution[v], Solution.MAIN_WAY))
					else:
						is_way_v_possible[vertex_way.index] = true
						s.ensure(s.iff(s.eq(is_solution[v], Solution.MAIN_WAY),
							s.eq(is_solution[vertex_way.index], way)))
				for v in range(n_vertices):
					if (!is_way_v_possible[v]):
						s.ensure(s.neq(is_solution[v], way))
						
			s.ensure(s.eq(s.count_true(s.eq(is_start, way)), '1'))
			s.ensure(s.eq(s.count_true(s.eq(is_end, way)), '1'))
			s.ensure(s.graph_vertex_connected(s.eq(is_solution, way), edge_list))
