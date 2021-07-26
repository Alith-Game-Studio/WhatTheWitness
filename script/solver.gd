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
	var passed: Array
	var is_start: Array
	var is_end: Array
	func solve(input_puzzle, max_solution_count):
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
		for v in range(n_vertices):
			if (sugar_solution[is_start[v]]):
				visited_vertices[v] = true
				var vertices = [v]
				var ok = true
				while(ok):
					ok = false
					for v2 in vertice_neighbors[v]:
						if (sugar_solution[passed[v2]]):
							if !(v2 in visited_vertices):
								visited_vertices[v2] = true
								vertices.append(v2)
								v = v2
								ok = true
								break
				solution_state.vertices.append(vertices)
		solution_line.state_stack.append(solution_state)
		solution_line.started = true
		solution_line.progress = 1.0
		return solution_line
				
	func ensure_segment():
		is_start = s.new_bool_array(n_vertices, true)
		is_end = s.new_bool_array(n_vertices)
		passed = s.new_bool_array(n_vertices, true)
		var is_start_or_end = s.or_(is_start, is_end)
		s.ensure(s.imp(is_start, passed))
		s.ensure(s.imp(is_end, passed))
		for v in range(n_vertices):
			if (!puzzle.vertices[v].is_puzzle_start):
				s.ensure(s.iff(is_start[v], s.FALSE))
			if (!puzzle.vertices[v].is_puzzle_end):
				s.ensure(s.iff(is_end[v], s.FALSE))
			var connectivity_conditions = []
			for v2 in vertice_neighbors[v]:
				connectivity_conditions.append(passed[v2])
			var degree = s.count_true(connectivity_conditions)
			s.ensure(s.imp(s.and_(passed[v], s.not_(is_start_or_end[v])), s.eq(degree, '2')))
			s.ensure(s.imp(is_start_or_end[v], s.eq(degree, '1')))
		s.ensure(s.eq(s.count_true(is_start), '1'))
		s.ensure(s.eq(s.count_true(is_end), '1'))
		s.ensure(s.graph_vertex_connected(passed, edge_list))
