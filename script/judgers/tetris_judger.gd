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
	var has_multi = false
	var has_hollow = false
	var has_weak = false
	var has_strong = false
	for decorator_id in region.decorator_dict['tetris']:
		var response = validator.decorator_responses[decorator_id]
		var shapes = response.decorator.shapes
		var is_hollow = response.decorator.is_hollow
		if (response.decorator.is_hollow):
			has_hollow = true
		if (response.decorator.is_multi):
			has_multi = true
		if (response.decorator.is_weak):
			has_weak = true
		else:
			has_strong = true
			cell_count += -len(shapes) if is_hollow else len(shapes)
			for shape in shapes:
				var area = calc_area(shape)
				area_sum += -area if is_hollow else area
	var ok = true
	if (has_strong):
		if (has_multi): # area not useful in multi tetris
			ok = judge_csp(validator, region, true, false)
			if (has_hollow):
				ok = ok or judge_csp(validator, region, false, false)
		elif ((cell_count == 0 and abs(area_sum) <= 1e-2)): # zero sum
			ok = judge_csp(validator, region, false, false)
		else:
			var total_facet_area = 0.0
			for facet_index in region.facet_indices:
				var facet = validator.puzzle.facets[facet_index]
				var facet_area = 0.0
				for i in range(2, len(facet.vertices)):
					facet_area += calc_triangle_area(facet.vertices[0].pos, facet.vertices[i - 1].pos, facet.vertices[i].pos)
				total_facet_area += abs(facet_area)
			# print(cell_count, ' vs ', len(region.facet_indices))
			# print(area_sum, ' vs_f ', total_facet_area)
			if (cell_count == len(region.facet_indices) and abs(area_sum - total_facet_area) <= 1e-2):
				ok = judge_csp(validator, region, true, false)
			else:
				ok = false
		if (!ok):
			if (require_errors):
				for decorator_id in region.decorator_dict['tetris']:
					var response = validator.decorator_responses[decorator_id]
					if (!response.decorator.is_weak):
						response.state = Validation.DecoratorResponse.ERROR
			else:
				return false
	if (has_weak):
		if (!judge_csp(validator, region, true, true)):
			ok = false
			if (require_errors):
				for decorator_id in region.decorator_dict['tetris']:
					var response = validator.decorator_responses[decorator_id]
					if (response.decorator.is_weak):
						response.state = Validation.DecoratorResponse.ERROR	
	return ok

func judge_csp(validator, region: Validation.Region, fill: bool, weak: bool):
	var clauses = []
	var n_id = len(validator.region_of_facet)
	for i in range(n_id):
		var occupy = 1 if fill and validator.region_of_facet[i].index == region.index else 0
		var init_variables = {}
		if (weak):
			init_variables[n_id] = 1
		n_id += 1
		clauses.append([init_variables, occupy])
	for decorator_id in region.decorator_dict['tetris']:
		var response = validator.decorator_responses[decorator_id]
		if (weak == response.decorator.is_weak):
			var shape_clause = [{}, 1]
			var is_hollow = response.decorator.is_hollow
			for covering in response.decorator.covering:
				shape_clause[0][n_id] = 1
				for f_id in covering:
					clauses[f_id][0][n_id] = -1 if is_hollow else 1
				n_id += 1
				if (response.decorator.is_multi):  # fill negative variables for optional duplication
					shape_clause[0][n_id] = -1
					n_id += 1
			clauses.append(shape_clause)
			
	var solver = CSPSolver
	solver.Clear()
	for clause in clauses:
		# print('Add clause:', clause)
		solver.AddClause(clause[0], clause[1])
	var result = solver.Satisfiable()
	# print('Result:', result)
	solver.Clear()
	return result

func solver_test():
	var solver = CSPSolver
	solver.Clear()
	solver.AddClause({0: 1, 1: 1, 2: -1}, 2)
	print(solver.Satisfiable())
	solver.PrintSolution()
	# solution: [1, 1, 0]
	
	solver = CSPSolver
	solver.Clear()
	solver.AddClause({2: 1, 4: 1}, 1)
	solver.AddClause({3: 1, 5: 1}, 1)
	solver.AddClause({1: 1, 3: 1}, 1)
	solver.AddClause({2: 1, 4: 1, 6: 1}, 1)
	solver.AddClause({1: 1, 6: 1}, 1)
	solver.AddClause({1: 1, 3: 1}, 1)
	solver.AddClause({2: 1, 5: 1, 6: 1}, 1)
	print(solver.Satisfiable())
	solver.PrintSolution()
	# solution: [any, 1, 0, 0, 1, 1, 0]
