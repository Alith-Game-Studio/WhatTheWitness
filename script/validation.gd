extends Node

class Validator:
	
	var solution_validity: int # 0: unknown, 1: correct, -1: wrong
	var errors: Array
	var decorator_list: Array
	var regions: Array
	var vertex_covered: Array
	
	func validate(puzzle: Graph.Puzzle, solution: Solution.SolutionLine):
		decorator_list.clear()
		vertex_covered.clear()
		for i in range(len(puzzle.vertices)):
			var vertex = puzzle.vertices[i]
			vertex_covered.append(false)
			if (vertex.decorator.rule != 'none'):
				decorator_list.append([vertex.decorator.rule, vertex, i, Graph.VERTEX_ELEMENT])
		for line in solution.lines:
			for segment in line:
				vertex_covered[segment[0].start_index] = true
				vertex_covered[segment[0].end_index] = true
		get_regions(puzzle)
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
