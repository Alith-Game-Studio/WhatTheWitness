extends Node

class DecoratorResponse:
	var decorator
	var rule: String
	var pos: Vector2
	var vertex_index: int
	var state: int
	var data: Object
	
	const NORMAL = 0
	const ERROR = 1
	const ELIMINATED = 2
	const CONVERTED = 3

class Validator:
	
	var solution_validity: int # 0: unknown, 1: correct, -1: wrong
	var decorator_responses: Array
	var regions: Array
	var vertex_covered: Array
	
	func validate(puzzle: Graph.Puzzle, solution: Solution.SolutionLine):
		decorator_responses.clear()
		vertex_covered.clear()
		for i in range(len(puzzle.vertices)):
			var vertex = puzzle.vertices[i]
			vertex_covered.append(false)
			if (vertex.decorator.rule != 'none'):
				var response = DecoratorResponse.new()
				response.decorator = vertex.decorator
				response.rule = vertex.decorator.rule
				response.pos = vertex.pos
				response.vertex_index = vertex.index
				response.state = DecoratorResponse.ERROR
				response.data = null
				decorator_responses.append(response)
		# get_regions(puzzle)
		print(regions)
		solution.validity = -1
	
	func reset():
		pass
	
	func get_regions(puzzle: Graph.Puzzle):
		var visit = []
		var stack = []
		regions.clear()
		for i in range(len(puzzle.facets)):
			visit.append(false)
		for i in range(len(puzzle.facets)):
			var facet = puzzle.facets[i]
			if (!visit[i]):
				stack.push_back(i)
				visit[i] = true
				var single_region = []
				while (!stack.empty()):
					var fid = stack.pop_back()
					single_region.push_back(fid)
					for edge_tuple in puzzle.facets[fid].edge_tuples:
						var mid_v = puzzle.edge_detector_node[edge_tuple]
						if (!vertex_covered[mid_v]):
							for j in puzzle.edge_shared_facets[edge_tuple]:
								if (!visit[j]):
									stack.push_back(j)
									visit[j] = true
				regions.append(single_region)
