extends Node2D

var graph = preload("res://script/graph.gd").new()
var better_xml = preload("res://script/better_xml.gd").new()
var solution = preload("res://script/solution.gd").Solution.new()
var validator = preload("res://script/validation.gd").Validator.new()
var view_scale = 100.0
var view_origin = Vector2(200, 300)
var puzzle = graph.load_from_xml('res://puzzles/symmetry.wit')
var mouse_start_position = null
var filament = preload("res://fliament.gd").FilamentSolution.new()
var is_drawing_solution = false

func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PoolVector2Array()
	points_arc.push_back(center)
	var colors = PoolColorArray([color])

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors, [], null, null, true)

func _draw():
	draw_witness()

func _ready():
	normalize_view()	

func normalize_view():
	var screen_size = get_viewport().size
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
	view_scale = min(screen_size.x * 0.8 / (max_x - min_x), 
					 screen_size.y * 0.8 / (max_y - min_y))
	view_origin = screen_size / 2 - Vector2((max_x + min_x) / 2, (max_y + min_y) / 2) * view_scale
	

func draw_filament(filament_nails):
	for vertex in filament_nails:
		# add_circle(vertex, 0.01, Color.white)
		for vertex2 in filament_nails:
			if ((vertex2 - vertex).length() < 0.11):
				add_line(vertex, vertex2, 0.01, Color.white)
	if (filament.started):
		for i in range(len(filament.path_points)):
			var start = filament.path_points[i][0]
			var end = filament.end_pos if i + 1 == len(filament.path_points) else filament.path_points[i + 1][0]
			add_line(start, end, 0.01, Color.lightblue)
		 

func draw_witness():
	for vertex in puzzle.vertices:
		add_circle(vertex.pos, puzzle.line_width / 2.0, puzzle.line_color)
	for edge in puzzle.edges:
		add_line(edge.start.pos, edge.end.pos, puzzle.line_width, puzzle.line_color)
	for vertex in puzzle.vertices:
		if (vertex.decorator != null):
			vertex.decorator.draw_foreground(self, vertex, 0, puzzle)
	for edge in puzzle.edges:
		if (edge.decorator != null):
			edge.decorator.draw_foreground(self, edge, 1, puzzle)
	for facet in puzzle.facets:
		if (facet.decorator != null):
			facet.decorator.draw_foreground(self, facet, 2, puzzle)
	if (solution.started):
		for way in range(puzzle.n_ways):
			var color = puzzle.solution_colors[way]
			if (validator.solution_validity == -1):
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
	
	
func add_circle(pos, radius, color):
	draw_circle(world_to_screen(pos), radius * view_scale - 0.5, color)
	draw_arc(world_to_screen(pos), radius * view_scale - 0.5, 0.0, 2 * PI, 64, color, 1.0, true)
	
func add_line(pos1, pos2, width, color):
	draw_line(world_to_screen(pos1), world_to_screen(pos2), color, width * view_scale, true)

func add_polygon(pos_list, color):
	var result_list = []
	for pos in pos_list:
		result_list.push_back(world_to_screen(pos))
	draw_polygon(result_list, PoolColorArray([color]), [], null, null, true)

func screen_to_world(position):
	return (position - view_origin) / view_scale

func world_to_screen(position):
	return position * view_scale + view_origin

func _input(event):
	if (event is InputEventMouseButton and event.is_pressed()):
		if (is_drawing_solution):
			if (solution.is_completed()):
				validator.validate(puzzle, solution)
			is_drawing_solution = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			if (mouse_start_position != null):
				Input.warp_mouse_position(mouse_start_position)
				mouse_start_position = null
		else:
			if (solution.try_start_solution_at(puzzle, screen_to_world(event.position))):
				validator.reset()
				mouse_start_position = event.position
				is_drawing_solution = true
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		self.update()
	if (event is InputEventMouseMotion):
		if (is_drawing_solution):
			var split = 5
			for i in range(split):
				solution.try_continue_solution(puzzle, event.relative / view_scale / split)
			self.update()
	
