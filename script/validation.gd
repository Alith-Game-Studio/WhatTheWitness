extends Node

class DecoratorResponse:
	var decorator
	var rule: String
	var pos: Vector2
	var vertex_index: int
	var state: int
	var data: Object
	var index: int
	
	const NORMAL = 0
	const ERROR = 1
	const ELIMINATED = 2
	const CONVERTED = 3
	
class Region:
	
	var facet_indices: Array
	var vertice_indices: Array
	var decorator_indices: Array
	var decorator_dict: Dictionary
	var index
	
	func _to_string():
		return '[%d] Facets: %s, Decorators: %s\n' % [index, str(facet_indices), str(decorator_dict)]
	

class Validator:
	
	var solution_validity: int # 0: unknown, 1: correct, -1: wrong
	var decorator_responses: Array
	var decorator_response_of_vertex: Dictionary
	var regions: Array
	var region_of_facet: Array
	var vertex_region: Array # -1: unknown; -2, -3, ...: covered by solution; 0, 1, ...: in regions
	var puzzle: Graph.Puzzle
	var solution: Solution.DiscreteSolutionState
	
	func validate(input_puzzle: Graph.Puzzle, input_solution: Solution.SolutionLine):
		puzzle = input_puzzle
		solution = input_solution.state_stack[-1]
		decorator_responses = []
		decorator_response_of_vertex = {}
		for i in range(len(puzzle.vertices)):
			var vertex = puzzle.vertices[i]
			if (vertex.decorator.rule != 'none'):
				var response = DecoratorResponse.new()
				response.decorator = vertex.decorator
				response.rule = vertex.decorator.rule
				response.pos = vertex.pos
				response.vertex_index = vertex.index
				response.state = DecoratorResponse.NORMAL
				response.data = null
				response.index = len(decorator_responses)
				decorator_responses.append(response)
				decorator_response_of_vertex[i] = response
		vertex_region = []
		for i in range(len(puzzle.vertices)):
			vertex_region.push_back(-1)
		for way in range(puzzle.n_ways):
			for v in solution.vertices[way]:
				vertex_region[v] = -way - 2
		var visit = []
		var stack = []
		regions = []
		for i in range(len(puzzle.facets)):
			visit.append(false)
			region_of_facet.append(-1)
		for i in range(len(puzzle.facets)):
			var facet = puzzle.facets[i]
			if (!visit[i]):
				stack.push_back(i)
				visit[i] = true
				var single_region = Region.new()
				while (!stack.empty()):
					var fid = stack.pop_back()
					single_region.facet_indices.push_back(fid)
					for edge_tuple in puzzle.facets[fid].edge_tuples:
						var mid_v = puzzle.edge_detector_node[edge_tuple]
						if (vertex_region[mid_v] == -1):
							for j in puzzle.edge_shared_facets[edge_tuple]:
								if (!visit[j]):
									stack.push_back(j)
									visit[j] = true
				single_region.index = len(regions)
				for f in single_region.facet_indices:
					region_of_facet[f] = single_region
					vertex_region[puzzle.facets[f].center_vertex_index] = single_region.index
					for edge_tuple in puzzle.facets[f].edge_tuples:
						var mid_v = puzzle.edge_detector_node[edge_tuple]
						for v_id in [edge_tuple[0], edge_tuple[1], mid_v]:
							if (vertex_region[v_id] == -1):
								vertex_region[v_id] = single_region.index
				regions.append(single_region)
		for i in range(len(puzzle.vertices)):
			if (vertex_region[i] >= 0):
				if (i in decorator_response_of_vertex):
					regions[vertex_region[i]].decorator_indices.append(decorator_response_of_vertex[i].index)
					var rule = decorator_response_of_vertex[i].rule
					if (!(rule in regions[vertex_region[i]].decorator_dict)):
						regions[vertex_region[i]].decorator_dict[rule] = []
					regions[vertex_region[i]].decorator_dict[rule].append(decorator_response_of_vertex[i].index)
				regions[vertex_region[i]].vertice_indices.append(i)
		
		print(regions)
		print(vertex_region)
		
		return BasicJudgers.judge_all(self)
