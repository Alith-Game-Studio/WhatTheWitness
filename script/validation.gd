extends Node

class DecoratorResponse:
	var decorator
	var rule: String
	var color = null
	var pos: Vector2
	var vertex_index: int
	var state: int
	var state_before_elimination: int
	var clone_source_decorator
	var index: int
	
	const NORMAL = 0
	const ERROR = 1
	const ELIMINATED = 2
	const CONVERTED = 3
	const NO_ELIMINATION_CHANGES = -1
	
class Region:
	
	var facet_indices: Array
	var vertice_indices: Array
	var decorator_indices: Array
	var decorator_dict: Dictionary
	var is_near_solution_line: bool
	var index
	
	func _to_string():
		return '[%d] Facets: %s, Decorators: %s\n' % [index, str(facet_indices), str(decorator_dict)]
	
	func has_any(rule):
		return rule in decorator_dict and len(decorator_dict[rule]) != 0

class Validator:
	
	var elimination_happended: bool
	var solution_validity: int # 0: unknown, 1: correct, -1: wrong
	var decorator_responses: Array
	var decorator_responses_of_vertex: Dictionary
	var regions: Array
	var region_of_facet: Array
	var vertex_region: Array # -1: unknown; -2, -3, ...: covered by solution; 0, 1, ...: in regions
	var puzzle: Graph.Puzzle
	var solution: Solution.DiscreteSolutionState
	var has_boxes: bool
	var has_lasers: bool
	
	func alter_rule(decorator_index, region, new_rule):
		var old_rule = decorator_responses[decorator_index].rule
		if (!old_rule.begins_with('!')):
			region.decorator_dict[old_rule].erase(decorator_index)
		decorator_responses[decorator_index].rule = new_rule
		if (!new_rule.begins_with('!')):
			if (!(new_rule in region.decorator_dict)):
				region.decorator_dict[new_rule] = []
			region.decorator_dict[new_rule].append(decorator_index)

	func add_decorator(decorator, pos, vertex_index):
		var response = DecoratorResponse.new()
		response.decorator = decorator
		response.rule = decorator.rule
		if (decorator.color != null):
			response.color = decorator.color
		response.pos = pos
		response.vertex_index = vertex_index
		response.state = DecoratorResponse.NORMAL
		response.state_before_elimination = DecoratorResponse.NO_ELIMINATION_CHANGES
		response.index = len(decorator_responses)
		decorator_responses.append(response)
		return response
		
	func push_vertex_decorator_response(v, response):
		if not (v in decorator_responses_of_vertex):
			decorator_responses_of_vertex[v] = [response]
		else:
			decorator_responses_of_vertex[v].append(response)
	
	func validate(input_puzzle: Graph.Puzzle, input_solution: Solution.SolutionLine):
		puzzle = input_puzzle
		solution = input_solution.state_stack[-1]
		decorator_responses = []
		decorator_responses_of_vertex = {}
		elimination_happended = false
		for i in range(len(puzzle.vertices)):
			var vertex = puzzle.vertices[i]
			if not (vertex.decorator.rule in ['none', 'cosmic-alien', 'cosmic-house']):
				var response = add_decorator(vertex.decorator, vertex.pos, i)
				push_vertex_decorator_response(i, response)
		var ghost_properties = null
		var ghost_manager = null
		for i in range(len(puzzle.decorators)):
			var decorator = puzzle.decorators[i]
			if (decorator.rule == 'box'):
				if (len(solution.event_properties) > i):
					var v = solution.event_properties[i]
					var vertex = puzzle.vertices[v]
					var response = add_decorator(puzzle.decorators[i].inner_decorator, vertex.pos, v)
					push_vertex_decorator_response(v, response)
				has_boxes = true
			elif (decorator.rule == 'laser-manager'):
				has_lasers = true
			elif (puzzle.decorators[i].rule == 'ghost-manager'):
				ghost_manager = puzzle.decorators[i]
				ghost_properties = solution.event_properties[i]
			elif (puzzle.decorators[i].rule == 'cosmic-manager'):
				puzzle.decorators[i].prepare_validation(self, solution.event_properties[i])
		vertex_region = []
		for i in range(len(puzzle.vertices)):
			vertex_region.push_back(-1)
		for way in range(puzzle.n_ways):
			if (way >= len(solution.vertices)):
				continue
			var vertices_way = solution.vertices[way]
			for i in range(len(vertices_way)):
				var v = vertices_way[i]
				if (ghost_manager != null and ghost_manager.is_solution_point_ghosted(ghost_properties, way, i)):
					continue
				if (v >= len(puzzle.vertices)):
					continue
				vertex_region[v] = -way - 2
		var stack = []
		regions = []
		for i in range(len(puzzle.facets)):
			region_of_facet.append(-1)
		for v1 in range(len(puzzle.vertices)):
			if (vertex_region[v1] == -1):
				stack.push_back(v1)
				var new_region = Region.new()
				new_region.index = len(regions)
				regions.append(new_region)
				vertex_region[v1] = new_region.index
				while (!stack.empty()):
					var v2 = stack.pop_back()
					for v3 in puzzle.vertice_region_neighbors[v2]:
						if (vertex_region[v3] == -1):
							vertex_region[v3] = new_region.index
							stack.push_back(v3)
						elif (vertex_region[v3] < -1):
							new_region.is_near_solution_line = true
					var facet = puzzle.vertices[v2].linked_facet
					if (facet != null):
						region_of_facet[facet.index] = new_region
						new_region.facet_indices.append(facet.index)

		for i in range(len(puzzle.vertices)):
			if (vertex_region[i] >= 0):
				if (i in decorator_responses_of_vertex):
					for response in decorator_responses_of_vertex[i]:
						regions[vertex_region[i]].decorator_indices.append(response.index)
						var rule = response.rule
						if (!(rule in regions[vertex_region[i]].decorator_dict)):
							regions[vertex_region[i]].decorator_dict[rule] = []
						regions[vertex_region[i]].decorator_dict[rule].append(response.index)
				regions[vertex_region[i]].vertice_indices.append(i)
		
		return BasicJudgers.judge_all(self, true)
	
	
