extends Node

const UPSAMPLING_FACTOR = 2

onready var initial_viewport_size = get_viewport().size
onready var initial_window_size = OS.window_size


class PuzzleCanvas:
	
	var drawing_target
	var view_scale = 100.0
	var view_origin = Vector2(200, 300)
	
	var puzzle
	var override_color = null
	var canvas_size = null
		
	func normalize_view(canvas_size, canvas_margin = 0.9, puzzle_border = 0.8):
		if (len(puzzle.vertices) == 0):
			return
		var min_x = puzzle.vertices[0].pos.x
		var max_x = puzzle.vertices[0].pos.x
		var min_y = puzzle.vertices[0].pos.y
		var max_y = puzzle.vertices[0].pos.y
		for vertex in puzzle.vertices:
			max_x = max(max_x, vertex.pos.x)
			min_x = min(min_x, vertex.pos.x)
			max_y = max(max_y, vertex.pos.y)
			min_y = min(min_y, vertex.pos.y)
		self.canvas_size = canvas_size
		view_scale = min(canvas_size.x * canvas_margin / (max_x - min_x + puzzle_border), 
						 canvas_size.y * canvas_margin / (max_y - min_y + puzzle_border))
		view_origin = canvas_size / 2 - Vector2((max_x + min_x) / 2, (max_y + min_y) / 2) * view_scale
	
	func add_circle(pos, radius, color):
		# drawing_target.draw_circle(pos * view_scale, radius * view_scale - 0.5, color if override_color == null else override_color)
		# drawing_target.draw_arc(pos * view_scale, radius / 2 * view_scale, 0.0, 2 * PI, 64, color if override_color == null else override_color, radius / 2 * view_scale, true)
		drawing_target.draw_circle(pos * view_scale, radius * view_scale, color if override_color == null else override_color)
		
	func add_line(pos1, pos2, width, color):
		# drawing_target.draw_line(pos1 * view_scale, pos2 * view_scale, color if override_color == null else override_color, width * view_scale, true)
		drawing_target.draw_line(pos1 * view_scale, pos2 * view_scale, color if override_color == null else override_color, width * view_scale)
	
	func add_gradient_lines(pos_list, width, colors):
		var result_list = []
		for pos in pos_list:
			result_list.push_back(pos * view_scale)
		drawing_target.draw_polyline_colors(result_list, 
			colors if override_color == null else PoolColorArray([override_color]),
			width * view_scale)
	
	func add_rect(pos1, pos2, width, color):
		# drawing_target.draw_line(Vector2((pos1.x + pos2.x) / 2, pos1.y) * view_scale, Vector2((pos1.x + pos2.x) / 2, pos2.y) * view_scale, color if override_color == null else override_color, (pos2.x - pos1.x) * view_scale, true)
		drawing_target.draw_line(Vector2((pos1.x + pos2.x) / 2, pos1.y) * view_scale, Vector2((pos1.x + pos2.x) / 2, pos2.y) * view_scale, color if override_color == null else override_color, (pos2.x - pos1.x) * view_scale)
		
	func add_texture(center, size, texture):
		var origin = center * view_scale
		var screen_size = size * view_scale
		var rect = Rect2(origin - screen_size / 2, screen_size)
		drawing_target.draw_texture_rect(texture, rect, false)
		
	func add_polygon(pos_list, color):
		var result_list = []
		for pos in pos_list:
			result_list.push_back(pos * view_scale)
		# drawing_target.draw_polygon(result_list, PoolColorArray([color if override_color == null else override_color]), [], null, null, true)
		drawing_target.draw_polygon(result_list, PoolColorArray([color if override_color == null else override_color]))
		
	func screen_to_world(position):
		return (position * UPSAMPLING_FACTOR - view_origin) / view_scale

	func draw_puzzle(target):
		if (canvas_size == null):
			return
		drawing_target = target
		drawing_target.draw_line(Vector2(0, canvas_size.y / 2), Vector2(canvas_size.x, canvas_size.y / 2), puzzle.background_color, canvas_size.y)
		drawing_target.draw_set_transform(view_origin, 0.0, Vector2(1.0, 1.0))
		for vertex in puzzle.vertices:
			if (!vertex.hidden):
				add_circle(vertex.pos, puzzle.line_width * 0.5, puzzle.line_color)
				if (vertex.is_puzzle_start):
					add_circle(vertex.pos, puzzle.start_size, puzzle.line_color)
		for edge in puzzle.edges:
			add_line(edge.start.pos, edge.end.pos, puzzle.line_width, puzzle.line_color)
		for vertex in puzzle.vertices:
			if (vertex.decorator != null):
				drawing_target.draw_set_transform(view_origin + vertex.pos * view_scale, vertex.decorator.angle, Vector2(1.0, 1.0))
				vertex.decorator.draw_foreground(self, vertex, 0, puzzle)

		drawing_target.draw_set_transform(view_origin, 0.0, Vector2(1.0, 1.0))
		for decorator in puzzle.decorators:
			decorator.draw_foreground(self, null, -1, puzzle)
	
	func draw_validation(target, puzzle, validator, time):
		if (validator == null): # unknown
			return
		var error_transparency = (sin(time * 6 + PI / 4) + 1) / 2
		var eliminator_fading = min(1.0, max(0.0, time - 1.0)) * 0.65
		var clone_fading = min(0.5, max(0.0, time)) * 2
		drawing_target = target
		drawing_target.draw_set_transform(view_origin, 0.0, Vector2(1.0, 1.0))
		for decorator_response in validator.decorator_responses:
			var draw_error = false
			var draw_eliminated = 0.0
			var draw_cloned = decorator_response.clone_source_decorator != null
			if (validator.elimination_happended and time < 1.0):
				draw_error = decorator_response.state_before_elimination == Validation.DecoratorResponse.ERROR or \
					(decorator_response.state_before_elimination == Validation.DecoratorResponse.NO_ELIMINATION_CHANGES and \
					decorator_response.state == Validation.DecoratorResponse.ERROR)
			else:
				draw_error = decorator_response.state == Validation.DecoratorResponse.ERROR
				draw_eliminated = decorator_response.state == Validation.DecoratorResponse.ELIMINATED
			if (draw_cloned):
				override_color = Color(puzzle.background_color.r, puzzle.background_color.g, puzzle.background_color.b, clone_fading * 0.8)
				drawing_target.draw_set_transform(view_origin + decorator_response.pos * view_scale, decorator_response.decorator.angle, Vector2(1.0, 1.0))
				decorator_response.clone_source_decorator.draw_foreground(self, puzzle.vertices[decorator_response.vertex_index], 0, puzzle)
				override_color = Color(decorator_response.color.r, decorator_response.color.g, decorator_response.color.b, clone_fading)
				drawing_target.draw_set_transform(view_origin + decorator_response.pos * view_scale, decorator_response.decorator.angle, Vector2(1.0, 1.0))
				decorator_response.decorator.draw_foreground(self, puzzle.vertices[decorator_response.vertex_index], 0, puzzle)
			if (draw_error and (!draw_cloned or time > 0.5)):
				override_color = Color(1.0, 0.0, 0.0, error_transparency)
				drawing_target.draw_set_transform(view_origin + decorator_response.pos * view_scale, decorator_response.decorator.angle, Vector2(1.0, 1.0))
				decorator_response.decorator.draw_foreground(self, puzzle.vertices[decorator_response.vertex_index], 0, puzzle)
			elif (draw_eliminated):
				override_color = Color(puzzle.background_color.r, puzzle.background_color.g, puzzle.background_color.b, eliminator_fading)
				drawing_target.draw_set_transform(view_origin + decorator_response.pos * view_scale, decorator_response.decorator.angle, Vector2(1.0, 1.0))
				decorator_response.decorator.draw_foreground(self, puzzle.vertices[decorator_response.vertex_index], 0, puzzle)
				
		override_color = null
		
	func draw_additive_layer(target, solution, validator, time):
		drawing_target = target
		drawing_target.draw_set_transform(view_origin, 0.0, Vector2(1.0, 1.0))
		for i in range(len(puzzle.decorators)):
			puzzle.decorators[i].draw_additive_layer(self, i, -1, puzzle, solution)

	func draw_solution(target, solution, validator, time):
		drawing_target = target
		drawing_target.draw_set_transform(view_origin, 0.0, Vector2(1.0, 1.0))
		for i in range(len(puzzle.decorators)):
			puzzle.decorators[i].draw_below_solution(self, i, -1, puzzle, solution)
		for vertex in puzzle.vertices:
			if (vertex.decorator != null):
				drawing_target.draw_set_transform(view_origin + vertex.pos * view_scale, vertex.decorator.angle, Vector2(1.0, 1.0))
				vertex.decorator.draw_below_solution(self, vertex, 0, puzzle, solution)
		drawing_target.draw_set_transform(view_origin, 0.0, Vector2(1.0, 1.0))
		if (solution != null and solution.started):
			var state = solution.state_stack[-1]
			var main_way = Solution.MAIN_WAY
			var vertices_main_way = state.vertices[main_way]
			for way in range(puzzle.n_ways):
				if (way >= len(state.vertices)):
					continue
				if (len(state.solution_stage) > way and state.solution_stage[way] == Solution.SOLUTION_STAGE_GHOST):
					continue
				var vertices_way = state.vertices[way]
				var color = puzzle.solution_colors[way]
				if (validator != null and validator.elimination_happended and time < 1.0):
					color = Color.black
				if (solution.validity == -1):
					color = Color.black
				elif (solution.validity == 0): # drawing illumination
					color = Color(1 - (1 - color.r) * 0.6, 1 - (1 - color.g) * 0.6, 1 - (1 - color.b) * 0.6, color.a)
				var delta_shift = Vector2.ZERO
				var last_pos = puzzle.vertices[vertices_way[0]].pos
				if (len(state.solution_stage) > way and state.solution_stage[way] == Solution.SOLUTION_STAGE_SNAKE):
					if (len(vertices_way) > 1 and !puzzle.vertices[vertices_way[-1]].is_puzzle_end):
						last_pos = last_pos * (1 - solution.progress) + puzzle.vertices[vertices_way[1]].pos * solution.progress
				add_circle(last_pos, puzzle.start_size, color)
				for i in range(1, len(vertices_way)):
					if(vertices_way[i - 1] >= len(puzzle.vertices) or vertices_way[i] >= len(puzzle.vertices)):
						continue
					var segment = [puzzle.vertices[vertices_way[i - 1]].pos, puzzle.vertices[vertices_way[i]].pos]
					var percentage
					if (i + 1 == len(vertices_way)):
						var segment_main = [puzzle.vertices[vertices_main_way[-2]].pos, puzzle.vertices[vertices_main_way[-1]].pos]
						var main_line_length = (segment_main[1] - segment_main[0]).length()
						var line_length = (segment[1] - segment[0]).length()
						var segment_progress = solution.progress
						percentage = segment_progress * main_line_length / line_length
					else:
						percentage = 1.0
					var pos = segment[0] * (1.0 - percentage) + segment[1] * percentage
					if (last_pos != null):
						add_line(last_pos, pos, puzzle.line_width, color)
						add_circle(pos, puzzle.line_width / 2.0, color)
					last_pos = pos

		for vertex in puzzle.vertices:
			if (vertex.decorator != null):
				drawing_target.draw_set_transform(view_origin + vertex.pos * view_scale, vertex.decorator.angle, Vector2(1.0, 1.0))
				vertex.decorator.draw_above_solution(self, vertex, 0, puzzle, solution)
		drawing_target.draw_set_transform(view_origin, 0.0, Vector2(1.0, 1.0))
		for i in range(len(puzzle.decorators)):
			puzzle.decorators[i].draw_above_solution(self, i, -1, puzzle, solution)

	func set_transform(new_pos=null, new_angle=null):
		if (new_pos == null):
			drawing_target.draw_set_transform(view_origin, 0.0, Vector2(1.0, 1.0))
		else:
			drawing_target.draw_set_transform(view_origin + new_pos * view_scale, new_angle, Vector2(1.0, 1.0))
