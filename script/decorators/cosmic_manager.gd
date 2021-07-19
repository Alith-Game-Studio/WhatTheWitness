extends "../decorator.gd"

var rule = 'cosmic-manager'

var alien_vertices = []
var house_vertices = []
var vertex_detectors = {}
func add_alien(v):
	alien_vertices.append(v)
	
func add_house(v):
	house_vertices.append(v)
	
func draw_above_solution(canvas, owner, owner_type, puzzle, solution):
	var id = owner
	if (solution == null or !solution.started or len(solution.state_stack[-1].event_properties) <= id):
		return
	var states = solution.state_stack[-1].event_properties[id]
	
	for alien_v in alien_vertices:
		if not (alien_v in states):
			continue
		if (states[alien_v] != -1):
			var background_color = puzzle.background_color
			puzzle.vertices[alien_v].decorator.draw_alien(canvas, puzzle, puzzle.vertices[alien_v].pos,
				Color(background_color.r, background_color.g, background_color.b, 0.7))
	
	for house_v in house_vertices:
		if not (house_v in states):
			continue
		if (states[house_v] != -1):
			var alien_v = states[house_v]
			var alien_color = puzzle.vertices[alien_v].decorator.color
			puzzle.vertices[house_v].decorator.draw_house(canvas, puzzle, puzzle.vertices[house_v].pos,
				alien_color, true)
	
	for way in range(puzzle.n_ways):
		if not (-way - 1 in states):
			continue
		var way_state = states[-way - 1]
		if (way_state != -1):
			var way_vertices = solution.state_stack[-1].vertices[way]
			var alien_v = way_state
			var alien_color = puzzle.vertices[alien_v].decorator.color
			canvas.add_circle(solution.get_current_way_position(puzzle, way),
				puzzle.line_width * 0.3,
				alien_color
			)
	
func prepare_validation(validator, states):
	var puzzle = validator.puzzle
	for alien_v in alien_vertices:
		if not (alien_v in states):
			continue
		if (states[alien_v] == -1):
			var vertex = puzzle.vertices[alien_v]
			var response = validator.add_decorator(vertex.decorator, vertex.pos, alien_v)
			validator.push_vertex_decorator_response(alien_v, response)
	
	for house_v in house_vertices:
		if not (house_v in states):
			continue
		var vertex = puzzle.vertices[house_v]
		var response = validator.add_decorator(vertex.decorator, vertex.pos, house_v)
		if (states[house_v] != -1):
			var alien_v = states[house_v]
			var alien_color = puzzle.vertices[alien_v].decorator.color
			response.color = alien_color
		validator.push_vertex_decorator_response(house_v, response)
	
	for way in range(puzzle.n_ways):
		if not (-way - 1 in states):
			continue
		var way_state = states[-way - 1]
		if (way_state != -1):
			var way_end_v = validator.solution.vertices[way][-1]
			var alien_v = way_state
			var alien_color = puzzle.vertices[alien_v].decorator.color
			var response = validator.add_decorator(puzzle.vertices[alien_v].decorator, puzzle.vertices[way_end_v].pos, way_end_v)
			validator.push_vertex_decorator_response(way_end_v, response)

func init_property(puzzle, solution_state, start_vertex):
	var states = {}
	for alien_v in alien_vertices:
		states[alien_v] = -1
		vertex_detectors[alien_v] = []
		var facet = puzzle.vertices[alien_v].linked_facet
		if (facet != null):
			for edge_tuple in facet.edge_tuples:
				vertex_detectors[alien_v].append(puzzle.edge_detector_node[edge_tuple])
	for house_v in house_vertices:
		states[house_v] = -1
		vertex_detectors[house_v] = []
		var facet = puzzle.vertices[house_v].linked_facet
		if (facet != null):
			for edge_tuple in facet.edge_tuples:
				vertex_detectors[house_v].append(puzzle.edge_detector_node[edge_tuple])
	
	for way in range(puzzle.n_ways):
		states[-way - 1] = -1
	return states
	
func transist(puzzle: Graph.Puzzle, vertices, old_state):
	var new_state = {}
	for key in old_state:
		new_state[key] = old_state[key]
	for way in range(puzzle.n_ways):
		var way_state = new_state[-way - 1]
		var passing_vertex_id = vertices[way][-1]
		if (way_state != -1): # occupied
			for house_v in house_vertices:
				if (new_state[house_v] != -1):
					continue
				if (passing_vertex_id in vertex_detectors[house_v]):
					var alien_v = way_state
					var house_color = puzzle.vertices[house_v].decorator.color
					var alien_color = puzzle.vertices[alien_v].decorator.color
					if (house_color == Color.black or house_color == alien_color):
						new_state[alien_v] = house_v
						new_state[house_v] = alien_v
						way_state = -1
						break
		if (way_state == -1): # not occupied
			var aliens_on_board = []
			for alien_v in alien_vertices:
				if (new_state[alien_v] != -1):
					continue
				if (passing_vertex_id in vertex_detectors[alien_v]):
					aliens_on_board.append(alien_v)
			if (len(aliens_on_board) == 1):
				way_state = aliens_on_board[0]
				new_state[aliens_on_board[0]] = -2 - way
		new_state[-way - 1] = way_state
	return new_state

func property_to_string(states):
	var result = []
	for v in states:
		result.append('%d:%d' % [v, states[v]])
	return PoolStringArray(result).join(',')

func string_to_property(string):
	if (string != ''):
		var result = string.split(',')
		var states = {}
		for state_string in result:
			var key_value = state_string.split(':')
			if (len(key_value) == 2):
				states[int(key_value[0])] = int(key_value[1])
		return states
	return {}

