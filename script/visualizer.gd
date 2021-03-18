extends Node2D

var validator = Validation.Validator.new()
var canvas = Canvas.new(self)
var mouse_start_position = null
var is_drawing_solution = false
var puzzle

class Canvas:
	
	var drawing_target
	var puzzle
	var solution
	var view_scale = 100.0
	var view_origin = Vector2(200, 300)
	
	func _init(target):
		drawing_target = target

	func normalize_view(canvas_size):
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
		view_scale = min(canvas_size.x * 0.8 / (max_x - min_x), 
						 canvas_size.y * 0.8 / (max_y - min_y))
		view_origin = canvas_size / 2 - Vector2((max_x + min_x) / 2, (max_y + min_y) / 2) * view_scale
		
	func draw_witness():
		for vertex in puzzle.vertices:
			add_circle(vertex.pos, puzzle.line_width / 2.0, puzzle.line_color)
		for edge in puzzle.edges:
			add_line(edge.start.pos, edge.end.pos, puzzle.line_width, puzzle.line_color)
		for vertex in puzzle.vertices:
			if (vertex.decorator != null):
				vertex.decorator.draw_foreground(self, vertex, 0, puzzle, solution)
		for edge in puzzle.edges:
			if (edge.decorator != null):
				edge.decorator.draw_foreground(self, edge, 1, puzzle, solution)
		for facet in puzzle.facets:
			if (facet.decorator != null):
				facet.decorator.draw_foreground(self, facet, 2, puzzle, solution)
		for decorator in puzzle.decorators:
			decorator.draw_foreground(self, null, -1, puzzle, solution)
		if (solution.started):
			for way in range(puzzle.n_ways):
				var color = puzzle.solution_colors[way]
				if (solution.validity == -1):
					color = Color.black
				add_circle(solution.start_vertices[way].pos, puzzle.start_size, color)
				var last_pos = solution.start_vertices[way].pos
				for i in range(len(solution.progress)):
					var segment = solution.lines[way][i]
					var segment_main = solution.lines[solution.MAIN_WAY][i]
					var main_line_length = (segment_main[0].start.pos - segment_main[0].end.pos).length()
					var line_length = (segment[0].start.pos - segment[0].end.pos).length()
					
					var edge = segment[0]
					var percentage = solution.progress[i] * main_line_length / line_length
					if (segment[1]):
						percentage = 1.0 - percentage
					var pos = edge.start.pos * (1.0 - percentage) + edge.end.pos * percentage
					add_line(last_pos, pos, puzzle.line_width, color)
					add_circle(pos, puzzle.line_width / 2.0, color)
					last_pos = pos
		for vertex in puzzle.vertices:
			if (vertex.decorator != null):
				vertex.decorator.draw_above_solution(self, vertex, 0, puzzle, solution)
		for edge in puzzle.edges:
			if (edge.decorator != null):
				edge.decorator.draw_above_solution(self, edge, 1, puzzle, solution)
		for facet in puzzle.facets:
			if (facet.decorator != null):
				facet.decorator.draw_above_solution(self, facet, 2, puzzle, solution)
		for decorator in puzzle.decorators:
			decorator.draw_above_solution(self, null, -1, puzzle, solution)
	func add_circle(pos, radius, color):
		drawing_target.draw_circle(world_to_screen(pos), radius * view_scale - 0.5, color)
		drawing_target.draw_arc(world_to_screen(pos), radius * view_scale - 0.5, 0.0, 2 * PI, 64, color, 1.0, true)
		
	func add_line(pos1, pos2, width, color):
		drawing_target.draw_line(world_to_screen(pos1), world_to_screen(pos2), color, width * view_scale, true)

	func add_texture(center, size, texture):
		var origin = world_to_screen(center)
		var screen_size = size * view_scale
		var rect = Rect2(origin - screen_size / 2, screen_size)
		drawing_target.draw_texture_rect(texture, rect, false)
		
	func add_polygon(pos_list, color):
		var result_list = []
		for pos in pos_list:
			result_list.push_back(world_to_screen(pos))
		drawing_target.draw_polygon(result_list, PoolColorArray([color]), [], null, null, true)

	func screen_to_world(position):
		return (position - view_origin) / view_scale

	func world_to_screen(position):
		return position * view_scale + view_origin

func _draw():
	canvas.draw_witness()

func _ready():
	canvas.puzzle = Graph.load_from_xml(Gameplay.load_puzzle_path)
	canvas.solution = Solution.SolutionLine.new()
	canvas.normalize_view(get_viewport().size)	

func _physics_process(delta):
	update()

func _input(event):
	if (event is InputEventMouseButton and event.is_pressed()):
		if (is_drawing_solution):
			if (canvas.solution.is_completed()):
				validator.validate(canvas.puzzle, canvas.solution)
			is_drawing_solution = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			if (mouse_start_position != null):
				Input.warp_mouse_position(mouse_start_position)
				mouse_start_position = null
		else:
			if (canvas.solution.try_start_solution_at(canvas.puzzle, canvas.screen_to_world(event.position))):
				validator.reset()
				mouse_start_position = event.position
				is_drawing_solution = true
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if (event is InputEventMouseMotion):
		if (is_drawing_solution):
			var split = 5
			for i in range(split):
				canvas.solution.try_continue_solution(canvas.puzzle, event.relative / canvas.view_scale / split)
	
