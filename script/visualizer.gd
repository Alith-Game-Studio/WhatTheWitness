extends Node2D

var graph = preload("res://script/graph.gd").new()
var solution = preload("res://script/solution.gd").Solution.new()
var view_scale = 100.0
var puzzle = graph.create_sample_puzzle()
var mouse_start_position = null
var filament = preload("res://fliament.gd").FilamentSolution.new()
var filament_nails = create_filament_nails()

func create_filament_nails():
	var result = []
	for i in range(4):
		for j in range(4):
			for k in range(2):
				for l in range(2):
					result.append(Vector2(i + 1 + k * 0.1, j + 1 + l * 0.1))
	return result

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
	draw_filament()

func draw_filament():
	for vertex in filament_nails:
		add_circle(vertex, 0.01, Color.white)
	if (filament.started):
		for i in range(len(filament.path_points)):
			var start = filament.path_points[i][0]
			var end = filament.end_pos if i + 1 == len(filament.path_points) else filament.path_points[i + 1][0]
			add_line(start, end, 0.01, Color.white)
		 

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
	draw_circle(pos * view_scale, radius * view_scale, color)
	
func add_line(pos1, pos2, width, color):
	draw_line(pos1 * view_scale, pos2 * view_scale, color, width * view_scale, true)
	
func _input(event):
	if (event is InputEventMouseButton and event.is_pressed()):
		if (filament.try_start_solution_at(event.position / view_scale)):
			mouse_start_position = event.position
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			if (mouse_start_position != null):
				Input.warp_mouse_position(mouse_start_position)
				mouse_start_position = null
		self.update()
	if (event is InputEventMouseMotion):
		var split = 5
		for i in range(split):
			filament.try_continue_solution(filament_nails, event.relative / view_scale / split)
		self.update()
	
