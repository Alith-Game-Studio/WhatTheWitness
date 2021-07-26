extends Node

const rule_ids = {
	'point': 0,
	'!eliminated_point': 1,
	'square': 2,
	'!eliminated_square': 3,
	'star': 4,
	'!eliminated_star': 5,
	'tetris': 6,
	'!eliminated_tetris': 7,
	'eliminator': 8,
	'!eliminated_eliminator': 9,
}

class Solver:
	var puzzle: Graph.Puzzle
	var s = preload("res://script/judgers/sugar.gd").new()
	var n_vertices: int
	var n_edges: int
	var n_max_regions: int
	var vertice_neighbors: Array
	var vertices_region_neighbors: Array
	var edge_list: Array
	var region_edge_list: Array
	var solutions: Array
	var current_solution_id: int
	var is_solution: Array
	var is_start: Array
	var is_end: Array
	var is_region: Array
	var solution_state: Solution.DiscreteSolutionState
	var color_mapping: Dictionary
	var is_decorator: Array
	
	func add_to_color_mapping(color):
		if !(color in color_mapping):
			color_mapping[color] = len(color_mapping)
	
	func solve(input_puzzle, max_solution_count):
		solution_state = Solution.DiscreteSolutionState.new()
		puzzle = input_puzzle
		n_vertices = len(puzzle.vertices)
		n_edges = len(puzzle.edges)
		n_max_regions = len(puzzle.facets)
		print(puzzle)
		vertice_neighbors = []
		vertices_region_neighbors = []
		for v in range(n_vertices):
			vertice_neighbors.append([])
			vertices_region_neighbors.append([])
		for edge in puzzle.edges:
			vertice_neighbors[edge.start.index].append(edge.end.index)
			vertice_neighbors[edge.end.index].append(edge.start.index)
			vertices_region_neighbors[edge.start.index].append(edge.end.index)
			vertices_region_neighbors[edge.end.index].append(edge.start.index)
			edge_list.append([edge.start.index, edge.end.index])
			region_edge_list.append([edge.start.index, edge.end.index])
		for v_pair in puzzle.edge_shared_facets:
			if (v_pair[0] < v_pair[1]):
				var v_det = puzzle.edge_detector_node[v_pair]
				for f in puzzle.edge_shared_facets[v_pair]:
					var v_facet = puzzle.facets[f].center_vertex_index
					vertices_region_neighbors[v_facet].append(v_det)
					vertices_region_neighbors[v_det].append(v_facet)
					region_edge_list.append([v_facet, v_det])
			
		add_to_color_mapping(Color.black)
		for v in range(n_vertices):
			if (puzzle.vertices[v].decorator.color != null):
				add_to_color_mapping(puzzle.vertices[v].decorator.color)
		for way in range(puzzle.n_ways):
			add_to_color_mapping(puzzle.solution_colors[way])
		print(color_mapping)
		ensure_segment()
		ensure_points()
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
		is_decorator = s.new_int_array(n_vertices, -1, len(rule_ids) - 1)
		is_region = s.new_int_array(n_vertices, -1, n_max_regions - 1)
		for v in range(n_vertices):
			if (!puzzle.vertices[v].is_puzzle_start):
				s.ensure(s.eq(is_start[v], -1))
			if (!puzzle.vertices[v].is_puzzle_end):
				s.ensure(s.eq(is_end[v], -1))
			if (puzzle.vertices[v].decorator.rule == 'broken'):
				s.ensure(s.eq(is_solution[v], -1))
			if !(puzzle.vertices[v].decorator.rule in ['point']):
				s.ensure(s.eq(is_decorator[v], -1))
			s.ensure(s.xor(s.eq(is_solution[v], -1), s.eq(is_region[v], -1)))
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
		for v_pair in region_edge_list:
			s.ensure(s.or_(s.or_(s.eq(is_region[v_pair[0]], -1), s.eq(is_region[v_pair[1]], -1)),
				s.eq(is_region[v_pair[0]], is_region[v_pair[1]])))
		for region_id in range(n_max_regions):
			s.ensure(s.graph_vertex_connected(s.eq(is_region, region_id), region_edge_list))
	
	func ensure_points():
		for v in range(n_vertices):
			if (puzzle.vertices[v].decorator.rule == 'point'):
				var color = puzzle.vertices[v].decorator.color
				s.ensure(s.eq(is_decorator[v], rule_ids['point']))
				var satisfy_conditions = []
				for way in range(puzzle.n_ways):
					if (color == Color.black or color == puzzle.solution_colors[way]):
						satisfy_conditions.append(s.eq(is_solution[v], way))
				s.ensure(s.imp(s.eq(is_decorator[v], rule_ids['point']),
					s.fold_or(satisfy_conditions)))
			
