extends Node

const SOLUTION_STAGE_EXTENSION = 0
const SOLUTION_STAGE_SNAKE = 1
const SOLUTION_STATE_LINE_TRANSLATION = 2

const MAIN_WAY = 0

class DiscreteSolutionState:
	var vertices: Array
	var event_properties: Array
	var solution_stage: int
	
	func _init():
		vertices = []
		event_properties = []
		solution_stage = SOLUTION_STAGE_EXTENSION
		
	func copy():
		var result = DiscreteSolutionState.new()
		result.vertices = vertices.duplicate(true)
		result.event_properties = event_properties.duplicate(true)
		result.solution_stage = solution_stage
		return result
		
	func get_vertex_position(puzzle, way, id):
		return puzzle.vertices[vertices[way][id]].pos
		
	func get_end_position(puzzle, way):
		return puzzle.vertices[vertices[way][-1]].pos
		
	func get_end_vertex(puzzle, way):
		return puzzle.vertices[vertices[way][-1]]
		
	func is_retraction(puzzle, main_way_vertex_id):
		if (solution_stage == SOLUTION_STAGE_EXTENSION):
			if (len(vertices[MAIN_WAY]) >= 2):
				return main_way_vertex_id == vertices[MAIN_WAY][-2]
			return false
		
	func transist(puzzle, new_vertex_ids):
		if (solution_stage == SOLUTION_STAGE_EXTENSION):
			var new_state = copy()
			for way in range(puzzle.n_ways):
				new_state.vertices[way].push_back(new_vertex_ids[way])
			return new_state
	
	func get_symmetry_point(puzzle, way, pos):
		if (way == 0):
			return pos
		if (puzzle.symmetry_type == Graph.SYMMETRY_ROTATIONAL):
			return (pos - puzzle.symmetry_center).rotated(2 * PI * way / puzzle.n_ways) + puzzle.symmetry_center
		
	func get_symmetry_vector(puzzle, way, vec):
		if (way == 0):
			return vec
		if (puzzle.symmetry_type == Graph.SYMMETRY_ROTATIONAL):
			return vec.rotated(2 * PI * way / puzzle.n_ways)
		
	func get_nearest_start(puzzle, pos):
		var best_dist = puzzle.start_size
		var result = null
		for vertex in puzzle.vertices:
			if (vertex.decorator.rule == 'start'):
				var dist = (pos - vertex.pos).length()
				if (dist < best_dist):
					result = vertex
					best_dist = dist
		return result
		
	func initialize(puzzle, pos):
		var est_start_vertex = get_nearest_start(puzzle, pos)
		if (est_start_vertex == null):
			return false
		vertices.clear()
		for way in range(puzzle.n_ways):
			var est_way_start_pos = get_symmetry_point(puzzle, way, est_start_vertex.pos)
			var way_start_vertex = get_nearest_start(puzzle, est_way_start_pos)
			if (way_start_vertex == null):
				return false
			vertices.push_back([way_start_vertex.index])
		solution_stage = SOLUTION_STAGE_EXTENSION
		return true

class SolutionLine:
	var started: bool
	var state_stack: Array
	var progress: float
	var validity = 0
	var vertices_occupied: Array
	
	func det(v1, v2):
		return v1.x * v2.y - v2.x * v1.y
	
	func try_start_solution_at(puzzle, pos):
		var state = DiscreteSolutionState.new()
		if (state.initialize(puzzle, pos)):
			started = true
			progress = 1.0
			state_stack.clear()
			state_stack.push_back(state)
		else:
			started = false
			state_stack.clear()
		return started
	
	func is_completed(puzzle):
		if (!started):
			return false
		var crossroad_vertex = state_stack[-1].get_end_vertex(puzzle, MAIN_WAY)
		if (crossroad_vertex == null):
			return false
		return crossroad_vertex.decorator != null and crossroad_vertex.decorator.rule == 'end'
		
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
	
	func try_continue_solution(puzzle, delta):
		if (!started):
			return
		if (delta.length() < 1e-6):
			return
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
			if (chosen_edge != null):
				var edge = chosen_edge[0]
				var vertex_id = chosen_edge[1].index
				if (state_stack[-1].is_retraction(puzzle, vertex_id)):
					progress = 1.0 - 1e-6
				else:
					var new_state = state_stack[-1].transist(puzzle, [vertex_id])
					state_stack.push_back(new_state)
					progress = 1e-6
			else:
				return
		if (len(state_stack) > 1):
			var v1 = state_stack[-1].get_end_vertex(puzzle, MAIN_WAY)
			var v2 = state_stack[-2].get_end_vertex(puzzle, MAIN_WAY)
			var edge_vec = v1.pos - v2.pos
			var edge_length = edge_vec.length()
			
			# calculate upper limit (lower limit is always 0)
			var limit = 1.0 + 1e-6
			# calculate new progress
			var projected_length = edge_vec.normalized().dot(delta) / edge_length
			var projected_det = abs(det(edge_vec.normalized(), delta)) / edge_length
			var projected_progress = progress + projected_length
			var encourage_extension = false
			if (v1.is_attractor):
				if (v2.is_attractor):
					encourage_extension = progress > 0.5
				else:
					encourage_extension = true
			if (encourage_extension):
				projected_progress += projected_det * 0.5 # encourage
			else:
				projected_progress -= projected_det * 0.5 # discorage
			if (projected_progress <= 0.0):
				state_stack.pop_back()
				progress = 1.0 - 1e-6
				return
			if (projected_progress >= limit):
				projected_progress = limit
			progress = projected_progress
	
		
		
