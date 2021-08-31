extends Node

const SOLUTION_STAGE_EXTENSION = 0
const SOLUTION_STAGE_SNAKE = 1
const SOLUTION_STATE_LINE_TRANSLATION = 2
const SOLUTION_STAGE_GHOST = 3

const MAIN_WAY = 0

class DiscreteSolutionState:
	var vertices: Array
	var event_properties: Array
	var solution_stage: Array
	
	func _init():
		vertices = []
		event_properties = []
		solution_stage = []
		
	func copy():
		var result = DiscreteSolutionState.new()
		result.vertices = vertices.duplicate(true)
		result.event_properties = event_properties.duplicate(true)
		result.solution_stage = solution_stage.duplicate(true)
		return result
		
	func get_vertex_position(puzzle, way, id):
		return puzzle.vertices[vertices[way][id]].pos
		
	func get_end_position(puzzle, way):
		return puzzle.vertices[vertices[way][-1]].pos
		
	func get_end_vertex(puzzle, way):
		return puzzle.vertices[vertices[way][-1]]
		
	func is_retraction(puzzle, main_way_vertex_id):
		if (len(vertices[MAIN_WAY]) >= 2):
			return main_way_vertex_id == vertices[MAIN_WAY][-2]
		return false
		
	func transist(puzzle, main_way_vertex_id):
		var limit = 1.0 + 1e-6
		var main_way_pos = puzzle.vertices[main_way_vertex_id].pos
		var blocked_by_boxes = false
		var new_state = copy()
		var main_way_dir = (main_way_pos - puzzle.vertices[vertices[MAIN_WAY][-1]].pos).normalized()
		var snake_points = []
		var new_snake_points = []
		var ghost_properties = null
		var new_ghost_properties = null
		var ghost_manager = null
		
		# preprocess
		for i in range(len(puzzle.decorators)):
			if (puzzle.decorators[i].rule == 'snake-manager'):
				snake_points = event_properties[i]
				new_snake_points = new_state.event_properties[i]
			elif (puzzle.decorators[i].rule == 'ghost-manager'):
				ghost_manager = puzzle.decorators[i]
				ghost_properties = event_properties[i]
				new_ghost_properties = new_state.event_properties[i]
			elif (puzzle.decorators[i].rule == 'cosmic-manager'):
				new_state.event_properties[i] = puzzle.decorators[i].transist(puzzle, vertices, event_properties[i])
		
		# introduce new vertices
		for way in range(puzzle.n_ways):
			var way_vertex_id
			if (way == MAIN_WAY):
				way_vertex_id = main_way_vertex_id
			else:
				var way_crossroad_vertex_id = vertices[way][-1]
				var way_dir = get_symmetry_vector(puzzle, way, main_way_dir)
				way_vertex_id = -1
				for edge in puzzle.edges:
					var new_vertex_id
					var edge_dir
					if (edge.start.index == way_crossroad_vertex_id):
						new_vertex_id = edge.end.index
						edge_dir = edge.end.pos - edge.start.pos
					elif (edge.end.index == way_crossroad_vertex_id):
						new_vertex_id = edge.start.index
						edge_dir = edge.start.pos - edge.end.pos
					else:
						continue
					edge_dir = edge_dir.normalized()
					if ((edge_dir - way_dir).length() < 1e-4):
						way_vertex_id = new_vertex_id
						break
			if (way_vertex_id == -1):
				return [null, null]
			new_state.vertices[way].push_back(way_vertex_id)
			var line_stage = solution_stage[way]
			if (line_stage == SOLUTION_STAGE_SNAKE):
				new_state.vertices[way].pop_front()
				var v = new_state.vertices[way][0]
				if (v in new_snake_points):
					line_stage = SOLUTION_STAGE_EXTENSION
					new_snake_points.erase(v)
			if (line_stage == SOLUTION_STAGE_EXTENSION):
				if (vertices[way][-1] in new_snake_points):
					line_stage = SOLUTION_STAGE_SNAKE
			if (line_stage == SOLUTION_STAGE_GHOST):
				if (puzzle.vertices[vertices[way][-1]].decorator.rule == 'ghost'):
					if (ghost_manager.is_solution_point_ghosted(ghost_properties, way, len(vertices[way]) - 1)):
						continue
					var mark = len(vertices[way]) if puzzle.vertices[vertices[way][-1]].decorator.pattern == 0 else -len(vertices[way])
					new_ghost_properties[way].append(mark)
			new_state.solution_stage[way] = line_stage
		
		# limit calculation
		var main_edge_length = (puzzle.vertices[new_state.vertices[MAIN_WAY][-1]].pos - puzzle.vertices[new_state.vertices[MAIN_WAY][-2]].pos).length()
		var occupied_vertices = {}
		var endpoint_occupied = 0
		for way in range(puzzle.n_ways):
			for i in range(len(new_state.vertices[way]) - 1):
				if (ghost_manager != null and ghost_manager.is_solution_point_ghosted(new_ghost_properties, way, i)):
					continue
				occupied_vertices[new_state.vertices[way][i]] = 2 if i == 0 else 1
		for way in range(puzzle.n_ways):
			var second_point = puzzle.vertices[new_state.vertices[way][-2]]
			var end_point = puzzle.vertices[new_state.vertices[way][-1]]
			var edge_length = (end_point.pos - second_point.pos).length()
			if (abs(edge_length - main_edge_length) > 1e-3):
				limit = min(limit, 1.0 - 1e-6)
				if (edge_length < main_edge_length):
					limit = min(limit, 1.0 * edge_length / main_edge_length)
			if (new_state.vertices[way][-1] in occupied_vertices):
				if (ghost_manager != null and ghost_manager.is_solution_point_ghosted(new_ghost_properties, way, len(new_state.vertices[way]) - 1)):
					continue
				endpoint_occupied = max(endpoint_occupied, occupied_vertices[new_state.vertices[way][-1]])
			occupied_vertices[new_state.vertices[way][-1]] = 1 # end of solution also collides
			if (second_point.decorator.rule == 'self-intersection' and endpoint_occupied != 0):
				return [null, null]
			if end_point.decorator.rule != 'self-intersection':
				if (endpoint_occupied == 1): # colliding with other lines / self-colliding
					limit = min(limit, 1.0 - puzzle.line_width / edge_length)
				elif (endpoint_occupied == 2): # colliding with start points
					limit = min(limit, 1.0 - (puzzle.start_size + puzzle.line_width / 2) / edge_length)
			if (end_point.decorator.rule == 'broken'): # broken
				limit = min(limit, 0.5)
		for i in range(len(puzzle.decorators)):
			if (puzzle.decorators[i].rule == 'box'):
				var box_v = new_state.event_properties[i]
				if (!(box_v in occupied_vertices)):
					occupied_vertices[box_v] = 3 # box - box collision
		for i in range(len(puzzle.decorators)):
			if (puzzle.decorators[i].rule == 'box'):
				var box_v = new_state.event_properties[i]
				if (box_v in occupied_vertices and occupied_vertices[box_v] <= 2):
					var colliding_way = -1
					for way in range(puzzle.n_ways):
						var way_end_v = new_state.vertices[way][-1]
						if (way_end_v == box_v):
							if (colliding_way == -1):
								colliding_way = way
							else:
								colliding_way = -2
					if (colliding_way >= 0):
						var way_end_v = new_state.vertices[colliding_way][-1]
						var way_secondary_end_v = new_state.vertices[colliding_way][-2]
						var old_box_position = puzzle.vertices[way_end_v].pos
						var way_edge_dir = (old_box_position - puzzle.vertices[way_secondary_end_v].pos).normalized()
						if (!self.__perform_push(puzzle, new_state, i, way_edge_dir, occupied_vertices)):
							blocked_by_boxes = true
					else:
						blocked_by_boxes = true
		if (blocked_by_boxes):
			limit = min(limit, 0.22)
		
		# postprocess
		for i in range(len(puzzle.decorators)):
			if (puzzle.decorators[i].rule == 'laser-manager'):
				puzzle.decorators[i].update_lasers(new_state.event_properties[i], puzzle, new_state)
				
		return [new_state, limit]
	
	func __perform_push(puzzle, state, box_id, dir, occupied_vertices):
		var old_vertex_id = state.event_properties[box_id]
		var old_box_position = puzzle.vertices[old_vertex_id].pos
		var new_box_position = old_box_position + dir
		var new_vertex = puzzle.get_vertex_at(new_box_position)
		if (new_vertex == null):
			return false # out of bounds
		if (new_vertex.index in occupied_vertices):
			if (occupied_vertices[new_vertex.index] == 3): # recursive box-box pushing
				for i in range(len(puzzle.decorators)):
					if (puzzle.decorators[i].rule == 'box'):
						var box_v = state.event_properties[i]
						if (box_v == new_vertex.index):
							if (!__perform_push(puzzle, state, i, dir, occupied_vertices)):
								return false
			else:
				return false
		# todo: update occupied vertices in case multiple pushes
		state.event_properties[box_id] = new_vertex.index
		return true
	
	func get_symmetry_point(puzzle, way, pos):
		if (way == 0):
			return pos
		if (puzzle.symmetry_type == Graph.SYMMETRY_ROTATIONAL):
			return (pos - puzzle.symmetry_center).rotated(2 * PI * way / puzzle.n_ways) + puzzle.symmetry_center
		elif (puzzle.symmetry_type == Graph.SYMMETRY_REFLECTIVE):
			return (pos - puzzle.symmetry_center).reflect(puzzle.symmetry_normal) + puzzle.symmetry_center
		elif (puzzle.symmetry_type == Graph.SYMMETRY_PARALLEL):
			return pos + puzzle.symmetry_parallel_points[way] - puzzle.symmetry_parallel_points[MAIN_WAY]
		assert(false)
		
	func get_symmetry_vector(puzzle, way, vec):
		if (way == 0):
			return vec
		if (puzzle.symmetry_type == Graph.SYMMETRY_ROTATIONAL):
			return vec.rotated(2 * PI * way / puzzle.n_ways)
		elif (puzzle.symmetry_type == Graph.SYMMETRY_REFLECTIVE):
			return vec.reflect(puzzle.symmetry_normal)
		elif (puzzle.symmetry_type == Graph.SYMMETRY_PARALLEL):
			return vec
		assert(false)
			
	func pos_to_vertex_id(puzzle, pos, eps=1e-3):
		for vertex in puzzle.vertices:
			if (vertex.pos.distance_to(pos) < eps):
				return vertex.index
		return -1
		
	func get_nearest_start(puzzle, pos):
		var best_dist = puzzle.start_size
		var result = null
		for vertex in puzzle.vertices:
			if (vertex.is_puzzle_start):
				var dist = (pos - vertex.pos).length()
				if (dist < best_dist):
					result = vertex
					best_dist = dist
		return result
		
	func initialize(puzzle, pos):
		var possible_start_pos = []
		if (puzzle.symmetry_type == Graph.SYMMETRY_PARALLEL):
			for i in range(puzzle.n_ways):
				possible_start_pos.append(pos - puzzle.symmetry_parallel_points[i] + puzzle.symmetry_parallel_points[MAIN_WAY])
		else:
			possible_start_pos = [pos]
		for pos in possible_start_pos:
			vertices.clear()
			var est_start_vertex = get_nearest_start(puzzle, pos)
			if (est_start_vertex == null):
				continue
			var ok = true
			for way in range(puzzle.n_ways):
				var est_way_start_pos = get_symmetry_point(puzzle, way, est_start_vertex.pos)
				var way_start_vertex = get_nearest_start(puzzle, est_way_start_pos)
				if (way_start_vertex == null):
					ok = false
					break
				vertices.push_back([way_start_vertex.index])
				solution_stage.push_back(SOLUTION_STAGE_EXTENSION)
			if (ok):
				event_properties.clear()
				for decorator in puzzle.decorators:
					event_properties.append(decorator.init_property(puzzle, self, est_start_vertex))
				return true
		return false

class SolutionLine:
	var started: bool
	var state_stack: Array
	var progress: float
	var limit: float
	var validity = 0
	var vertices_occupied: Array
	
	func det(v1, v2):
		return v1.x * v2.y - v2.x * v1.y
	
	func try_start_solution_at(puzzle, pos):
		var state = DiscreteSolutionState.new()
		if (state.initialize(puzzle, pos)):
			validity = 0
			started = true
			progress = 1.0
			state_stack.clear()
			state_stack.push_back(state)
			return true
		else:
			return false
	
	func is_completed(puzzle):
		if (!started):
			return false
		var crossroad_vertex = state_stack[-1].get_end_vertex(puzzle, MAIN_WAY)
		if (crossroad_vertex == null):
			return false
		return crossroad_vertex.decorator != null and crossroad_vertex.is_puzzle_end and progress >= 0.8 # allow small gap
		
	func get_total_length(puzzle):
		if (!started):
			return 0.0
		var result = 0.0
		for i in range(len(state_stack[-1].vertices) - 1):
			var pos1 = state_stack[-1].get_vertex_position(puzzle, MAIN_WAY, i)
			var pos2 = state_stack[-1].get_vertex_position(puzzle, MAIN_WAY, i + 1)
			if (i + 2 == len(state_stack[-1].vertices)):
				result += (pos1 - pos2).length() * progress
			else:
				result += (pos1 - pos2).length() 
		return result
		
	func get_current_way_position(puzzle, way):
		if (!started):
			return null
		var way_vertices = state_stack[-1].vertices[way]
		if (len(way_vertices) == 1):
			return puzzle.vertices[way_vertices[0]].pos
		var p1 = puzzle.vertices[way_vertices[-1]].pos
		var p2 = puzzle.vertices[way_vertices[-2]].pos
		return p1 * progress + p2 * (1 - progress)
		
		
	
	func try_continue_solution(puzzle, delta):
		if (!started):
			return
		if (delta.length() < 1e-6):
			return
		delta = delta * Gameplay.mouse_speed
		var crossroad_vertex = state_stack[-1].get_end_vertex(puzzle, MAIN_WAY)
		if (len(state_stack) == 1 or progress >= 1.0):
			var chosen_edge = null
			var best_aligned_score = 0.0
			for edge in puzzle.edges:
				var target_vertex
				var edge_dir
				if (edge.start == crossroad_vertex):
					target_vertex = edge.end
					edge_dir = (edge.end.pos - edge.start.pos).normalized()
				elif (edge.end == crossroad_vertex):
					target_vertex = edge.start
					edge_dir = (edge.start.pos - edge.end.pos).normalized()
				else:
					continue
				var aligned_score = edge_dir.dot(delta)
				if (aligned_score > best_aligned_score):
					chosen_edge = [edge, target_vertex, edge_dir]
					best_aligned_score = aligned_score
			if (chosen_edge != null):
				var edge = chosen_edge[0]
				var vertex_id = chosen_edge[1].index
				if (state_stack[-1].is_retraction(puzzle, vertex_id)):
					progress = 1.0 - 1e-6
				else:
					var new_state_with_limit = state_stack[-1].transist(puzzle, vertex_id)
					var new_state = new_state_with_limit[0]
					var new_limit = new_state_with_limit[1]
					if (new_state != null):
						state_stack.push_back(new_state)
						limit = new_limit
						progress = 1e-6
					else:
						progress = 1.0 - 1e-6
			else:
				return
		if (len(state_stack) > 1):
			var v1 = state_stack[-1].get_end_vertex(puzzle, MAIN_WAY)
			var v2 = state_stack[-2].get_end_vertex(puzzle, MAIN_WAY)
			var edge_vec = v1.pos - v2.pos
			var edge_length = edge_vec.length()
			
			# calculate new progress
			var projected_length = edge_vec.normalized().dot(delta) / edge_length
			var projected_det = det(edge_vec.normalized(), delta) / edge_length
			var projected_progress = progress + projected_length
			var encourage_extension = false
			if (v1.is_attractor):
				if (v2.is_attractor):
					encourage_extension = progress > 0.5
				else:
					encourage_extension = true
			if (encourage_extension):
				if ([v2, v1] in puzzle.edge_turning_angles):
					var angle = puzzle.edge_turning_angles[[v2, v1]][1 if projected_det < 0 else 0]
					# print('encourage ', angle, ' to add ', projected_det / tan(angle / 2))
					projected_progress -= projected_det / tan(angle / 2 - 1e-6) * 0.5
			else: # discourage extension
				if ([v1, v2] in puzzle.edge_turning_angles):
					var angle = puzzle.edge_turning_angles[[v1, v2]][1 if projected_det > 0 else 0]
					# print('discourage ', angle, ' to minus ', projected_det / tan(angle / 2))
					projected_progress -= projected_det / tan(angle / 2 - 1e-6) * 0.5
			if (projected_progress <= 0.0):
				state_stack.pop_back()
				limit = 1.0 + 1e-6
				progress = 1.0 - 1e-6
				return
			if (projected_progress >= limit):
				projected_progress = limit
				
			var projected_position = v1.pos * projected_progress + v2.pos * (1 - projected_progress)
			var ok = true
			for decorator in puzzle.decorators:
				if (decorator.rule == 'filament-start'):
					var filament_percentage = decorator.filament_solution.try_continue_solution(decorator.nails, projected_position - decorator.filament_solution.end_pos)
					projected_progress = (projected_progress - progress) * filament_percentage + progress
			if (ok):
				progress = projected_progress
	
	
	func save_to_string(puzzle):
		var state = state_stack[-1]
		var line_result = []
		for state_way in state.vertices:
			var way_result = []
			for v in state_way:
				way_result.append(str(v))
			line_result.append( PoolStringArray(way_result).join(','))
		var line_string = PoolStringArray(line_result).join('|')
		var event_property_result = []
		for i in range(len(puzzle.decorators)):
			event_property_result.append(puzzle.decorators[i].property_to_string(state.event_properties[i]))
		var event_string = PoolStringArray(event_property_result).join('|')
		return PoolStringArray([line_string, event_string]).join('$')
		
	static func load_from_string(string, puzzle):
		var state = DiscreteSolutionState.new()
		var line_string_event_string = string.split('$')
		var line_string = line_string_event_string[0]
		var event_string = ''
		if (len(line_string_event_string) > 1):
			event_string = line_string_event_string[1]
		state.vertices = []
		var line_result = line_string.split('|')
		for way_string in line_result:
			var way_vertices = []
			var way_result = way_string.split(',')
			for vertex_string in way_result:
				way_vertices.append(int(vertex_string))
			state.vertices.append(way_vertices)
		state.event_properties = []
		var event_result = event_string.split('|')
		for i in range(len(puzzle.decorators)):
			state.event_properties.append(puzzle.decorators[i].string_to_property(event_result[i]))
		for i in range(len(puzzle.decorators)):
			puzzle.decorators[i].post_load_state(puzzle, state)
		
		var solution = SolutionLine.new()
		solution.started = true
		solution.validity = 1
		solution.state_stack = [state]
		solution.progress = 1.0
		
		return solution
		
		
