extends Node

const region_judgers = [
	'judge_region_points',
	'judge_region_squares',
	'judge_region_stars',
	'judge_region_triangles',
	'judge_region_arrows',
	'judge_region_tetris',
]

func judge_all(validator: Validation.Validator):
	var ok = true
	for region in validator.regions:
		var judger_ok = judge_region(validator, region, true)
		ok = judger_ok and ok
	return ok
	
	
func judge_region(validator: Validation.Validator, region: Validation.Region, require_errors: bool):
	var ok = true
	for region_judger in region_judgers:
		var region_judger_ok = call(region_judger, validator, region, require_errors)
		ok = ok and region_judger_ok
		if (!ok and !require_errors):
			return false
	return ok
	
func judge_region_squares(validator: Validation.Validator, region: Validation.Region, require_errors: bool):
	if (!('square' in region.decorator_dict)):
		return true
	var color = null
	var ok = true
	for decorator_id in region.decorator_dict['square']:
		var response = validator.decorator_responses[decorator_id]
		if (response.decorator.color != color):
			if (color == null):
				color = response.decorator.color
			else:
				ok = false
				break
	if (require_errors and !ok):
		for decorator_id in region.decorator_dict['square']:
			var response = validator.decorator_responses[decorator_id]
			response.state = Validation.DecoratorResponse.ERROR
	return ok

func judge_region_points(validator: Validation.Validator, region: Validation.Region, require_errors: bool):
	if (!('point' in region.decorator_dict)):
		return true
	if (require_errors):
		for decorator_id in region.decorator_dict['point']:
			var response = validator.decorator_responses[decorator_id]
			response.state = Validation.DecoratorResponse.ERROR
	return false
	
func judge_region_stars(validator: Validation.Validator, region: Validation.Region, require_errors: bool):
	if (!('star' in region.decorator_dict)):
		return true
	var color_dict = {}
	for decorator_id in region.decorator_indices:
		var response = validator.decorator_responses[decorator_id]
		if ('color' in response.decorator):
			if (response.decorator.color in color_dict):
				color_dict[response.decorator.color] += 1
			else:
				color_dict[response.decorator.color] = 1
	for decorator_id in region.decorator_dict['star']:
		var response = validator.decorator_responses[decorator_id]
		if (color_dict[response.decorator.color] != 2):
			if (require_errors):
				response.state = Validation.DecoratorResponse.ERROR
			else:
				return false
	return true
	
func judge_region_triangles(validator: Validation.Validator, region: Validation.Region, require_errors: bool):
	if (!('triangle' in region.decorator_dict)):
		return true
	for decorator_id in region.decorator_dict['triangle']:
		var ok = true
		var response = validator.decorator_responses[decorator_id]
		var facet = validator.puzzle.vertices[response.vertex_index].linked_facet
		if (facet == null): # the triangle is not placed on facets
			ok = false
		else:
			var count = 0
			for edge_tuple in facet.edge_tuples:
				var v = validator.puzzle.edge_detector_node[edge_tuple]
				if (validator.vertex_region[v] < -1): # covered by any line
					count += 1
			if (count != response.decorator.count):
				ok = false
		if (!ok):
			if (require_errors):
				response.state = Validation.DecoratorResponse.ERROR
			else:
				return false
	return true
	
func judge_region_arrows(validator: Validation.Validator, region: Validation.Region, require_errors: bool):
	if (!('arrow' in region.decorator_dict)):
		return true
	for decorator_id in region.decorator_dict['arrow']:
		var response = validator.decorator_responses[decorator_id]
		var origin = validator.puzzle.vertices[response.vertex_index].pos
		var direction = Vector2(-sin(response.decorator.angle), cos(response.decorator.angle))
		var count = 0
		for i in range(len(validator.puzzle.vertices)):
			if (validator.vertex_region[i] >= -1):
				continue
			if (i == response.vertex_index):
				continue
			var vertex_dir = validator.puzzle.vertices[i].pos - origin
			if (abs(vertex_dir.dot(direction) - vertex_dir.length()) < 1e-3):
				count += 1
				
		if (count != response.decorator.count):
			if (require_errors):
				response.state = Validation.DecoratorResponse.ERROR
			else:
				return false
	return true
	
	
func judge_region_tetris(validator: Validation.Validator, region: Validation.Region, require_errors: bool):
	if (!('tetris' in region.decorator_dict)):
		return true
	return TetrisJudger.judge_region_tetris_implementation(validator, region, require_errors)
	
