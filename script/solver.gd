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
	'triangle': 8,
	'!eliminated_triangle': 9,
	'eliminator': 10,
	'!eliminated_eliminator': 11,
	'circle-arrow': 12,
}

class Solver:
	var puzzle: Graph.Puzzle
	var s = preload("res://script/judgers/sugar.gd").new()
	var n_vertices: int
	var n_edges: int
	var n_max_regions: int
	var n_colors: int
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
	var is_tetris_covered: Array
	var is_direction: Array
	var rules: Dictionary
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
		rules = {}
		for v in range(n_vertices):
			vertice_neighbors.append([])
			vertices_region_neighbors.append([])
			if (puzzle.vertices[v].is_puzzle_end):
				n_max_regions += 1 # isolated ends
			var rule = puzzle.vertices[v].decorator.rule
			if !(rule in rules):
				rules[rule] = []
			rules[rule].append(v)
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
		n_colors = len(color_mapping)
		ensure_segment()
		if ('point' in rules):
			ensure_points()
		if ('square' in rules):
			ensure_squares()
		if ('tetris' in rules):
			ensure_tetris()
		if ('triangle' in rules):
			ensure_triangles()
		if ('star' in rules):
			ensure_stars()
		ensure_circle_arrow()
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
		is_tetris_covered = s.new_bool_array(n_vertices)
		for v in range(n_vertices):
			if (!puzzle.vertices[v].is_puzzle_start):
				s.ensure(s.eq(is_start[v], -1))
			if (!puzzle.vertices[v].is_puzzle_end):
				s.ensure(s.eq(is_end[v], -1))
			if (puzzle.vertices[v].decorator.rule == 'broken'):
				s.ensure(s.eq(is_solution[v], -1))
			if !(puzzle.vertices[v].decorator.rule in ['point', 'square', 'tetris', 'triangle', 'star', 'circle-arrow']):
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
				s.and_(s.eq(is_region[v_pair[0]], is_region[v_pair[1]]),
				s.iff(is_tetris_covered[v_pair[0]], is_tetris_covered[v_pair[1]]))
			))
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
			
	func ensure_squares():
		for v in range(n_vertices):
			if (puzzle.vertices[v].decorator.rule == 'square'):
				var color = puzzle.vertices[v].decorator.color
				s.ensure(s.eq(is_decorator[v], rule_ids['square']))
				for v2 in range(n_vertices):
					if (puzzle.vertices[v2].decorator.rule == 'square'):
						var color2 = puzzle.vertices[v2].decorator.color
						if (color != color2):
							s.ensure(
								s.imp(s.and_(s.eq(is_decorator[v], rule_ids['square']),
									s.eq(is_decorator[v2], rule_ids['square'])),
									s.neq(is_region[v], is_region[v2]))
							)
	
	func ensure_tetris():
		var coverings_facets_pos = []
		var coverings_facets_neg = []
		for f in range(len(puzzle.facets)):
			coverings_facets_pos.append([])
			coverings_facets_neg.append([])
		for v in range(n_vertices):
			if (puzzle.vertices[v].decorator.rule == 'tetris'):
				s.ensure(s.eq(is_decorator[v], rule_ids['tetris']))
				var coverings_shape = []
				for covering in puzzle.vertices[v].decorator.covering:
					var b = s.new_bool()
					coverings_shape.append(b)
					for f in covering:
						# var vf = puzzle.facets[f].center_vertex_index
						# var region_cond = s.eq(is_region[v], is_region[vf])
						# s.ensure(s.imp(b, region_cond))
						if (puzzle.vertices[v].decorator.is_hollow):
							coverings_facets_neg[f].append([b, v])
						else:
							coverings_facets_pos[f].append([b, v])
				s.ensure(s.eq(s.count_true(coverings_shape), 1))
		# todo: fix hollow
		for ref_v in range(n_vertices):
			if (puzzle.vertices[ref_v].decorator.rule == 'tetris'):
				for f in range(len(puzzle.facets)):
					var center_v = puzzle.facets[f].center_vertex_index
					var pos_cond = []
					var neg_cond = []
					for b_v_pair in coverings_facets_pos[f]:
						pos_cond.append(s.and_(b_v_pair[0], s.eq(is_region[ref_v], is_region[b_v_pair[1]])))
					for b_v_pair in coverings_facets_neg[f]:
						neg_cond.append(s.and_(b_v_pair[0], s.eq(is_region[ref_v], is_region[b_v_pair[1]])))
					s.ensure(s.eq(s.sub(s.count_true(pos_cond),
						s.count_true(neg_cond)), s.if_(s.and_(s.eq(is_region[center_v], is_region[ref_v]), is_tetris_covered[center_v]), 1, 0)))
				
	func ensure_triangles():
		for v in range(n_vertices):
			if (puzzle.vertices[v].decorator.rule == 'triangle'):
				s.ensure(s.eq(is_decorator[v], rule_ids['triangle']))
				var facet = puzzle.vertices[v].linked_facet
				if (facet == null): # the triangle is not placed on facets
					s.ensure(s.FALSE)
				else:
					var count = []
					for edge_tuple in facet.edge_tuples:
						var v2 = puzzle.edge_detector_node[edge_tuple]
						count.append(s.neq(is_solution[v2], -1))
					# print(s.eq(s.count_true(count), puzzle.vertices[v].decorator.count))
					s.ensure(s.eq(s.count_true(count), puzzle.vertices[v].decorator.count))
	
	func ensure_stars():
		for v in range(n_vertices):
			if (puzzle.vertices[v].decorator.rule == 'star'):
				s.ensure(s.eq(is_decorator[v], rule_ids['star']))
				var color = puzzle.vertices[v].decorator.color
				var choices = []
				for v2 in range(n_vertices):
					if (v2 == v):
						continue
					if (puzzle.vertices[v2].decorator.color == color):
						choices.append(s.eq(is_region[v], is_region[v2]))
				s.ensure(s.eq(s.count_true(choices), 1))
						
	func ensure_circle_arrow():
		var edges_direction = {}
		for v in range(n_vertices):
			var dir_conditions = []
			for v2 in vertice_neighbors[v]:
				var b = s.new_bool()
				dir_conditions.append(s.and_(s.eq(is_solution[v2], is_solution[v]), b))
				edges_direction[[v, v2]] = b
			s.ensure(s.imp(s.neq(is_solution[v], -1),
				s.eq(s.count_true(dir_conditions), s.if_(s.eq(is_start[v], -1), 1, 0))))
		for v_pair in edges_direction:
			if (v_pair[0] < v_pair[1]):
				s.ensure(s.imp(s.eq(is_solution[v_pair[0]], is_solution[v_pair[1]]), s.xor(edges_direction[v_pair], edges_direction[[v_pair[1], v_pair[0]]])))
		
		for v in range(n_vertices):
			if (puzzle.vertices[v].decorator.rule == 'circle-arrow'):
				var center = puzzle.vertices[v].pos
				var is_clockwise = puzzle.vertices[v].decorator.is_clockwise
				s.ensure(s.eq(is_decorator[v], rule_ids['circle-arrow']))
				var facet = puzzle.vertices[v].linked_facet
				if (facet == null):
					s.ensure(s.FALSE)
				else:
					var count = []
					for edge_tuple in facet.edge_tuples:
						var v1 = puzzle.edge_detector_node[edge_tuple]
						count.append(s.neq(is_solution[v1], -1))
						
						for v2 in vertice_neighbors[v1]:
							var cross = TetrisJudger.det(
								puzzle.vertices[v2].pos - center, 
								puzzle.vertices[v1].pos - center)
							if ((cross > 0 and is_clockwise) or (cross < 0 and !is_clockwise)):
								s.ensure(s.or_(s.eq(is_solution[v1], -1), edges_direction[[v1, v2]]))
					s.ensure(s.fold_or(count))
					
	
