extends Node2D

var graph = preload("res://script/graph.gd").new()
var better_xml = preload("res://script/better_xml.gd").new()
var solution = preload("res://script/solution.gd").Solution.new()
var view_scale = 100.0
var view_origin = Vector2(200, 300)
var puzzle = graph.load_from_xml('res://puzzles/miaoji.wit')
var mouse_start_position = null
var filament = preload("res://fliament.gd").FilamentSolution.new()

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
		add_circle(solution.start_pos, puzzle.start_size, puzzle.solution_color)
		var last_pos = solution.start_pos
		for segment in solution.segments:
			var edge = segment[0]
			var percentage = segment[2]
			if (segment[1]):
				percentage = 1.0 - percentage
			var pos = edge.start.pos * (1.0 - percentage) + edge.end.pos * percentage
			add_line(last_pos, pos, puzzle.line_width, puzzle.solution_color)
			add_circle(pos, puzzle.line_width / 2.0, puzzle.solution_color)
			last_pos = pos
	
	
func add_circle(pos, radius, color):
	draw_circle(world_to_screen(pos), radius * view_scale - 0.5, color)
	draw_arc(world_to_screen(pos), radius * view_scale - 0.5, 0.0, 2 * PI, 64, color, 1.0, true)
	
func add_line(pos1, pos2, width, color):
	draw_line(world_to_screen(pos1), world_to_screen(pos2), color, width * view_scale, true)

func add_polygon(pos_list, color):
	pass

func screen_to_world(position):
	return (position - view_origin) / view_scale

func world_to_screen(position):
	return position * view_scale + view_origin

func _input(event):
	if (event is InputEventMouseButton and event.is_pressed()):
		if (solution.try_start_solution_at(puzzle, screen_to_world(event.position))):
			filament.try_start_solution_at(solution.start_pos)
			mouse_start_position = event.position
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			filament.started = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			if (mouse_start_position != null):
				Input.warp_mouse_position(mouse_start_position)
				mouse_start_position = null
		self.update()
	if (event is InputEventMouseMotion):
		if (solution.started):
			var split = 5
			for i in range(split):
				solution.try_continue_solution(puzzle, event.relative / view_scale / split)
			self.update()
	
