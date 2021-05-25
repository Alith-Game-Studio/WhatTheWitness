extends Node


func det(v1, v2):
	return v1.x * v2.y - v2.x * v1.y
	
func calc_triangle_area(v1, v2, v3):
	return det(v2 - v1, v3 - v1) / 2

func calc_area(vertex_array: Array):
	var result = 0.0
	for i in range(2, len(vertex_array)):
		result += calc_triangle_area(vertex_array[0], vertex_array[i - 1], vertex_array[i])
	return abs(result)

func calc_area_vertices(vertex_array: Array):
	var result = 0.0
	for i in range(3, len(vertex_array)):
		result += calc_triangle_area(vertex_array[0], vertex_array[i - 1], vertex_array[i])
	return abs(result)
	
func judge_region_tetris_implementation(validator, region: Validation.Region, require_errors: bool):
	var cell_count = 0
	var area_sum = 0.0
	for decorator_id in region.decorator_dict['tetris']:
		var response = validator.decorator_responses[decorator_id]
		var shapes = response.decorator.shapes
		var is_hollow = response.decorator.is_hollow
		cell_count += -len(shapes) if is_hollow else len(shapes)
		for shape in shapes:
			var area = calc_area(shape)
			area_sum += -area if is_hollow else area
	var ok = false
	if (cell_count == 0 and abs(area_sum) <= 1e-2): # zero sum
		ok = judge_csp(validator, region, false)
	else:
		var total_facet_area = 0.0
		for facet_index in region.facet_indices:
			var facet = validator.puzzle.facets[facet_index]
			var facet_area = 0.0
			for i in range(2, len(facet.vertices)):
				facet_area += calc_triangle_area(facet.vertices[0].pos, facet.vertices[i - 1].pos, facet.vertices[i].pos)
			total_facet_area += abs(facet_area)
		print(cell_count, ' vs ', len(region.facet_indices))
		print(area_sum, ' vs_f ', total_facet_area)
		if (cell_count == len(region.facet_indices) and abs(area_sum - total_facet_area) <= 1e-2):
			ok = judge_csp(validator, region, true)
	if (!ok and require_errors):
		for decorator_id in region.decorator_dict['tetris']:
			var response = validator.decorator_responses[decorator_id]
			response.state = Validation.DecoratorResponse.ERROR
	return ok

func judge_csp(validator, region: Validation.Region, fill: bool):
	var clauses = []
	var n_id = len(validator.region_of_facet)
	for i in range(n_id):
		var occupy = 1 if fill and validator.region_of_facet[i].index == region.index else 0
		clauses.append([{}, occupy])
	for decorator_id in region.decorator_dict['tetris']:
		var response = validator.decorator_responses[decorator_id]
		var shape_clause = [{}, 1]
		var is_hollow = response.decorator.is_hollow
		for covering in response.decorator.covering:
			shape_clause[0][n_id] = 1
			for f_id in covering:
				clauses[f_id][0][n_id] = -1 if is_hollow else 1
			n_id += 1
		clauses.append(shape_clause)
	var solver = CSP.CSPSolver.new()
	for clause in clauses:
		# print('Add clause:', clause)
		solver.add_clause(clause[0], clause[1])
	var result = solver.satisfiable()
	# print('Result:', result)
	return result
