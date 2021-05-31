extends Node

const global_judgers = [
	'judge_covered_points',
	'judge_rings',
]

const region_judgers = [
	'judge_region_rings',
	'judge_region_eliminators',
	'judge_region_points',
	'judge_region_self_intersections',
	'judge_region_squares',
	'judge_region_stars',
	'judge_region_triangles',
	'judge_region_arrows',
	'judge_region_tetris',
]

func judge_all(validator: Validation.Validator, require_errors: bool):
	var ok = true
	for global_judger in global_judgers:
		var judger_ok = call(global_judger, validator, require_errors)
		ok = ok and judger_ok
		if (!ok and !require_errors):
			return false
	return ok

func __match_color(solution_color, point_color):
	if (point_color == Color.black): # black point matches every color
		return true
	return point_color == solution_color 

func judge_covered_points(validator: Validation.Validator, require_errors: bool):
	var all_ok = true
	for v in validator.decorator_response_of_vertex:
		var response = validator.decorator_response_of_vertex[v]
		if (response.rule == 'point' or response.rule == 'self-intersection'):
			var ok = true
			if (validator.vertex_region[v] < -1): # covered point
				if (response.rule == 'self-intersection'):
					var intersection_colors = []
					for way in range(validator.puzzle.n_ways):
						for solution_vertex_id in validator.solution.vertices[way]:
							if (solution_vertex_id == v):
								intersection_colors.append(validator.puzzle.solution_colors[way])
					if (len(intersection_colors) != 2): # must pass 2 times
						ok = false
					else:
						if (!__match_color(intersection_colors[0], response.decorator.color1) or
							!__match_color(intersection_colors[1], response.decorator.color2)):
							if (!__match_color(intersection_colors[1], response.decorator.color1) or
								!__match_color(intersection_colors[0], response.decorator.color2)):
								ok = false
				else: # point
					var way_id = -validator.vertex_region[v] - 2
					var color = response.color
					if (!__match_color(validator.puzzle.solution_colors[way_id], color)): 
						
						ok = false
			elif (validator.vertex_region[v] == -1): # points that do not belong to any region, neither covered
				ok = false
			if (!ok):
				if (require_errors):
					response.state = Validation.DecoratorResponse.ERROR
					all_ok = false
				else:
					return false
	return all_ok

func judge_rings(validator: Validation.Validator, require_errors: bool):
	var clonable_decorators = []
	var paste_positions = []
	for region in validator.regions:
		if (region.has_any('ring')):
			for decorator_id in region.decorator_indices:
				if (!(validator.decorator_responses[decorator_id].rule in ['ring', 'circle', 'point'])):
					if (validator.decorator_responses[decorator_id].decorator.color != null):
						clonable_decorators.append(decorator_id)
			for decorator_id in region.decorator_dict['ring']:
				paste_positions.append([decorator_id, region])
		if (region.has_any('circle')):
			for decorator_id in region.decorator_dict['circle']:
				paste_positions.append([decorator_id, region])
	if (len(paste_positions) == 0 or len(clonable_decorators) == 0):
		return judge_all_regions(validator, require_errors)
	else:
		for cloned_decorator_id in clonable_decorators:
			for paste_position in paste_positions:
				var decorator_response = validator.decorator_responses[paste_position[0]]
				validator.alter_rule(paste_position[0], paste_position[1], validator.decorator_responses[cloned_decorator_id].rule)
				decorator_response.clone_source_decorator = decorator_response.decorator
				decorator_response.decorator = validator.decorator_responses[cloned_decorator_id].decorator
			if (judge_all_regions(validator, false)):
				if (require_errors):
					return judge_all_regions(validator, require_errors)
				else:
					return true
			for paste_position in paste_positions:
				var decorator_response = validator.decorator_responses[paste_position[0]]
				decorator_response.decorator = decorator_response.clone_source_decorator
	if (require_errors):
		var rnd = clonable_decorators[randi() % len(clonable_decorators)]
		for paste_position in paste_positions:
			var decorator_response = validator.decorator_responses[paste_position[0]]
			validator.alter_rule(paste_position[0], paste_position[1], validator.decorator_responses[rnd].rule)
			decorator_response.clone_source_decorator = decorator_response.decorator
			decorator_response.decorator = validator.decorator_responses[rnd].decorator
			# print('current: ', decorator_response.rule)
		return judge_all_regions(validator, require_errors)
	else:
		return false
	
func judge_all_regions(validator: Validation.Validator, require_errors: bool):
	var ok = true
	for region in validator.regions:
		if (validator.puzzle.select_one_subpuzzle and !region.is_near_solution_line):
			continue
		var judger_ok = judge_region(validator, region, require_errors)
		ok = judger_ok and ok
	return ok
	
	
func judge_region(validator: Validation.Validator, region: Validation.Region, require_errors: bool):
	if (region.has_any('eliminator')):
		return judge_region_elimination(validator, region, require_errors)
	
	var ok = true
	for region_judger in region_judgers:
		var region_judger_ok = call(region_judger, validator, region, require_errors)
		ok = ok and region_judger_ok
		if (!ok and !require_errors):
			return false
	return ok
	
func judge_region_squares(validator: Validation.Validator, region: Validation.Region, require_errors: bool):
	if (!region.has_any('square')):
		return true
	var color = null
	var ok = true
	for decorator_id in region.decorator_dict['square']:
		var response = validator.decorator_responses[decorator_id]
		if (response.color != color):
			if (color == null):
				color = response.color
			else:
				ok = false
				break
	if (require_errors and !ok):
		for decorator_id in region.decorator_dict['square']:
			var response = validator.decorator_responses[decorator_id]
			response.state = Validation.DecoratorResponse.ERROR
	return ok

func judge_region_points(validator: Validation.Validator, region: Validation.Region, require_errors: bool):
	if (!region.has_any('point')):
		return true
	if (require_errors):
		for decorator_id in region.decorator_dict['point']:
			var response = validator.decorator_responses[decorator_id]
			response.state = Validation.DecoratorResponse.ERROR
	return false
	
func judge_region_self_intersections(validator: Validation.Validator, region: Validation.Region, require_errors: bool):
	if (!region.has_any('self-intersection')):
		return true
	if (require_errors):
		for decorator_id in region.decorator_dict['self-intersection']:
			var response = validator.decorator_responses[decorator_id]
			response.state = Validation.DecoratorResponse.ERROR
	return false
	
func judge_region_stars(validator: Validation.Validator, region: Validation.Region, require_errors: bool):
	if (!region.has_any('star')):
		return true
	var color_dict = {}
	for decorator_id in region.decorator_indices:
		var response = validator.decorator_responses[decorator_id]
		if (!response.rule.begins_with('!eliminated_')):
			if (response.color != null):
				if (response.color in color_dict):
					color_dict[response.color] += 1
				else:
					color_dict[response.color] = 1
	var ok = true
	for decorator_id in region.decorator_dict['star']:
		var response = validator.decorator_responses[decorator_id]
		if (color_dict[response.color] != 2):
			ok = false
			if (require_errors):
				response.state = Validation.DecoratorResponse.ERROR
			else:
				return false
	return ok
	
func judge_region_triangles(validator: Validation.Validator, region: Validation.Region, require_errors: bool):
	if (!region.has_any('triangle')):
		return true
	var all_ok = true
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
				all_ok = false
			else:
				return false
	return all_ok
	
func judge_region_arrows(validator: Validation.Validator, region: Validation.Region, require_errors: bool):
	if (!region.has_any('arrow')):
		return true
	var ok = true
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
				ok = false
			else:
				return false
	return ok
	
	
func judge_region_tetris(validator: Validation.Validator, region: Validation.Region, require_errors: bool):
	if (!region.has_any('tetris')):
		return true
	return TetrisJudger.judge_region_tetris_implementation(validator, region, require_errors)
	
func judge_region_rings(validator: Validation.Validator, region: Validation.Region, require_errors: bool):  # only for uneliminated eliminators
	if (!region.has_any('ring') and !region.has_any('circle')):
		return true
	if (require_errors):
		if (region.has_any('ring')):
			for decorator_id in region.decorator_dict['ring']:
				var response = validator.decorator_responses[decorator_id]
				response.state = Validation.DecoratorResponse.ERROR
		if (region.has_any('circle')):
			for decorator_id in region.decorator_dict['circle']:
				var response = validator.decorator_responses[decorator_id]
				response.state = Validation.DecoratorResponse.ERROR
	return false
	
func judge_region_eliminators(validator: Validation.Validator, region: Validation.Region, require_errors: bool):  # only for uneliminated eliminators
	if (!region.has_any('eliminator')):
		return true
	if (require_errors):
		for decorator_id in region.decorator_dict['eliminator']:
			var response = validator.decorator_responses[decorator_id]
			response.state = Validation.DecoratorResponse.ERROR
	return false

func __judge_region_elimination_case(validator: Validation.Validator, region: Validation.Region, require_errors: bool, \
	error_list: Array, eliminator_list: Array, eliminator_targets: Array):
	for i in range(len(eliminator_list)):
		for id in [eliminator_list[i], error_list[eliminator_targets[i]]]:
			validator.alter_rule(id, region, '!eliminated_' + validator.decorator_responses[id].rule)
			
	var ok = true
	for region_judger in region_judgers:
		var region_judger_ok = call(region_judger, validator, region, require_errors)
		ok = ok and region_judger_ok
		if (!ok and !require_errors):
			break
	for i in range(len(eliminator_list)):
		for id in [eliminator_list[i], error_list[eliminator_targets[i]]]:
			validator.alter_rule(id, region, validator.decorator_responses[id].rule.substr(12))
	if (require_errors):
		for i in range(len(eliminator_list)):
			for id in [eliminator_list[i], error_list[eliminator_targets[i]]]:
				validator.decorator_responses[id].state = Validation.DecoratorResponse.ELIMINATED
	return ok
		
	
func judge_region_elimination(validator: Validation.Validator, region: Validation.Region, require_errors: bool):
	var ok = true
	for region_judger in region_judgers:
		if (region_judger == 'judge_region_eliminators'):
			continue
		var region_judger_ok = call(region_judger, validator, region, true)
		ok = ok and region_judger_ok
	var error_list = []
	var eliminator_list = []
	for decorator_id in region.decorator_indices:
		var response = validator.decorator_responses[decorator_id]
		if (response.state == Validation.DecoratorResponse.ERROR):
			error_list.append(decorator_id)
		if (response.rule == 'eliminator'):
			eliminator_list.append(decorator_id)
		response.state_before_elimination = response.state
		response.state = Validation.DecoratorResponse.NORMAL
	if (len(error_list) == 0 and len(eliminator_list) == 1): 
		# special case: only one eliminator exists and there is no error
		# the eliminator cannot erase itself
		if (require_errors):
			validator.decorator_responses[eliminator_list[0]].state = Validation.DecoratorResponse.ERROR
			validator.decorator_responses[eliminator_list[0]].state_before_elimination = Validation.DecoratorResponse.ERROR
		return false
	validator.elimination_happended = true
	# otherwise, one eliminator can erase any error (which is the assumption in searching)
	# if it happens to eliminate itself, it is still a valid solution
	# since we can swap the targets of two eliminators to bypass this
	while(len(error_list) < len(eliminator_list)): # number of errors is insufficient
		var last_eliminator = eliminator_list.back()
		error_list.append(last_eliminator) # mark the eliminator as error
		eliminator_list.pop_back()
		validator.decorator_responses[last_eliminator].state_before_elimination = Validation.DecoratorResponse.ERROR
	var eliminator_targets = []
	var random_eliminator_targets = []
	var max_random_weights = randf()
	for i in range(len(eliminator_list)):
		eliminator_targets.append(i)
		random_eliminator_targets.append(i)
	var diff = len(error_list) - len(eliminator_list) 
	while true:
		if (__judge_region_elimination_case(validator, region, false, error_list, eliminator_list, eliminator_targets)):
			if (require_errors):
				return __judge_region_elimination_case(validator, region, require_errors, error_list, eliminator_list, eliminator_targets)
			else:
				return true
		var rnd = randf()
		if (rnd > max_random_weights):
			max_random_weights = rnd
			for i in range(len(eliminator_list)):
				random_eliminator_targets[i] = eliminator_targets[i]
		for j in range(len(eliminator_list) - 1, -1, -1):
			if (eliminator_targets[j] < j + diff):
				eliminator_targets[j] += 1
				for k in range(j + 1, len(eliminator_list)):
					eliminator_targets[k] = eliminator_targets[k - 1] + 1
				break
			if (j == 0): # all combination fails
				for i in range(len(eliminator_list)):
					if (require_errors):
						eliminator_targets[i] = random_eliminator_targets[i]
						return __judge_region_elimination_case(validator, region, require_errors, error_list, eliminator_list, eliminator_targets)
					else:
						return false
	
