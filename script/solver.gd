extends Node

class Solver:
	var state_stack: Array
	var puzzle: Graph.Puzzle
	var validation_counter = 0
	var max_validation_counter = 500
	
	func __is_completed():
		var crossroad_vertex = state_stack[-1].get_end_vertex(puzzle, Solution.MAIN_WAY)
		if (crossroad_vertex == null):
			return false
		return crossroad_vertex.decorator != null and crossroad_vertex.is_puzzle_end
		
	func __search():
		if (validation_counter >= max_validation_counter):
			return false
		var crossroad_vertex = state_stack[-1].get_end_vertex(puzzle, Solution.MAIN_WAY)
		var possible_transitions = []
		if (__is_completed()):
			if (validation_counter % 1000 == 0):
				print('Validating %d...' % validation_counter)
			validation_counter += 1
			var validator = Validation.Validator.new()
			return validator.validate(puzzle, self, false)
		for edge in puzzle.edges:
			var target_vertex
			var edge_dir
			if (edge.start == crossroad_vertex):
				target_vertex = edge.end
				possible_transitions.append(target_vertex.index)
			elif (edge.end == crossroad_vertex):
				target_vertex = edge.start
				possible_transitions.append(target_vertex.index)
			else:
				continue
		for vertex_id in possible_transitions:
			if (state_stack[-1].is_retraction(puzzle, vertex_id)):
				continue
			else:
				var new_state_with_limit = state_stack[-1].transist(puzzle, vertex_id)
				var new_state = new_state_with_limit[0]
				var new_limit = new_state_with_limit[1]
				if (new_state != null and new_limit >= 1.0):
					state_stack.push_back(new_state)
					if (__search()):
						return true
					else:
						state_stack.pop_back()
				else:
					continue
		return false
		
	func solve(init_puzzle):
		validation_counter = 0
		puzzle = init_puzzle
		for vertex in puzzle.vertices:
			if (vertex.is_puzzle_start):
				var solution_state = Solution.DiscreteSolutionState.new()
				var ok = solution_state.initialize(puzzle, vertex.pos)
				if (ok):
					state_stack.clear()
					state_stack.push_back(solution_state)
					if(__search()):
						return true
		return false
	
	func to_solution_line():
		print('total validations: %d' % validation_counter)
		var solution_line = Solution.SolutionLine.new()
		solution_line.state_stack = state_stack
		solution_line.progress = 1.0
		solution_line.started = true
		return solution_line
				
		
