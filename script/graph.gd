extends Node

var better_xml = preload("res://script/better_xml.gd").new()
var directory = Directory.new()

const VERTEX_ELEMENT = 0
const EDGE_ELEMENT = 1
const FACET_ELEMENT = 2
const GLOBAL_ELEMENT = 3

const SYMMETRY_ROTATIONAL = 0
const SYMMETRY_REFLECTIVE = 1
const SYMMETRY_PARALLEL = 2

func color(name):
	if (name.begins_with('#')):
		return Color(name)
	else:
		if (name == 'Navy'):
			return Color.navyblue
		elif (name == 'CornflowerBlue'):
			return Color.cornflower
		return ColorN(name)

class Vertex:
	var pos: Vector2
	var index: int
	var hidden: bool
	var decorator = load("res://script/decorators/no_decorator.gd").new()
	var is_attractor: bool
	var linked_facet
	var linked_edge_tuple
	var is_puzzle_start: bool
	var is_puzzle_end: bool
	func _init(x, y):
		pos.x = x
		pos.y = y

class Edge:
	var start: Vertex
	var end: Vertex
	var start_index: int
	var end_index: int
	func _init(v1, v2):
		start = v1
		end = v2
		
class Facet:
	var edge_tuples: Array
	var vertices: Array
	var center: Vector2
	var center_vertex_index: int
	var index: int
	func _init(vs):
		vertices = vs
		center = Vector2.ZERO
		for v in vertices:
			center += v.pos
		center /= len(vertices)
	
class Puzzle:
	var vertices: Array
	var edges: Array
	var facets: Array
	var line_color: Color
	var background_color: Color
	var solution_colors: Array
	var line_width: float
	var start_size: float
	var n_ways: int
	var select_one_subpuzzle = false # multi-panels
	var symmetry_type: int
	var symmetry_center: Vector2
	var symmetry_normal: Vector2
	var symmetry_parallel_points: Array
	var decorators : Array
	var edge_detector_node = {}
	var edge_shared_facets = {}
	var edge_turning_angles = {}
	var vertice_region_neighbors = null
	
	func get_vertex_at(position, eps=1e-3):
		for vertex in vertices:
			if ((vertex.pos - position).length() <= eps):
				return vertex
		return null
		
	func preprocess_tetris_covering():
		for v in vertices:
			if (v.decorator.rule == 'tetris'):
				v.decorator.calculate_covering(self)
		for decorator in decorators:
			if (decorator.rule == 'box'):
				if (decorator.inner_decorator.rule == 'tetris'):
					decorator.inner_decorator.calculate_covering(self)
		
	func preprocess_edge_angles():
		for e in edges:
			var start_turning_angles = [-PI, PI]
			var end_turning_angles = [-PI, PI]
			for e2 in edges:
				if (e == e2):
					continue
				if (e2.start.index == e.start.index or e2.end.index == e.start.index):
					var d1 = e.end.pos - e.start.pos
					var d2 = e2.end.pos - e2.start.pos
					if (e2.end.index == e.start.index):
						d2 = -d2
					var angle = d1.angle_to(d2)
					if (angle > 0):
						start_turning_angles[1] = min(start_turning_angles[1], angle)
					else:
						start_turning_angles[0] = max(start_turning_angles[0], angle)
				elif (e2.end.index == e.end.index or e2.start.index == e.end.index):
					var d1 = e.start.pos - e.end.pos
					var d2 = e2.start.pos - e2.end.pos
					if (e2.start.index == e.end.index):
						d2 = -d2
					var angle = d1.angle_to(d2)
					if (angle > 0):
						end_turning_angles[1] = min(end_turning_angles[1], angle)
					else:
						end_turning_angles[0] = max(end_turning_angles[0], angle)
			edge_turning_angles[[e.start, e.end]] = end_turning_angles
			edge_turning_angles[[e.end, e.start]] = start_turning_angles
	
	func build_neighbor_graph():
		vertice_region_neighbors = []
		for v in range(len(vertices)):
			vertice_region_neighbors.append([])
		for edge in edges:
			vertice_region_neighbors[edge.start.index].append(edge.end.index)
			vertice_region_neighbors[edge.end.index].append(edge.start.index)
		for v_pair in edge_shared_facets:
			if (v_pair[0] < v_pair[1]):
				var v_det = edge_detector_node[v_pair]
				for f in edge_shared_facets[v_pair]:
					var v_facet = facets[f].center_vertex_index
					vertice_region_neighbors[v_facet].append(v_det)
					vertice_region_neighbors[v_det].append(v_facet)
			
		
func push_vertex_vec(puzzle, pos, hidden=false):
	var result = len(puzzle.vertices)
	var vertex = Vertex.new(pos.x, pos.y)
	vertex.hidden = hidden
	vertex.index = len(puzzle.vertices)
	puzzle.vertices.push_back(vertex)
	return result

func push_edge_idx(puzzle, idx1, idx2):
	var result = len(puzzle.edges)
	var edge = Edge.new(puzzle.vertices[idx1], puzzle.vertices[idx2])
	edge.start_index = idx1
	edge.end_index = idx2
	puzzle.edges.push_back(edge)
	return edge
	
func __get_raw_element_center(puzzle, raw_element, element_type, id):
	if (element_type == EDGE_ELEMENT):
		var v1 = int(raw_element['Start'])
		var v2 = int(raw_element['End'])
		var p1 = puzzle.vertices[v1].pos
		var p2 = puzzle.vertices[v2].pos
		return p1 * 0.5 + p2 * 0.5
	elif (element_type == VERTEX_ELEMENT):
		return puzzle.vertices[id].pos
	elif (element_type == FACET_ELEMENT):
		var center = Vector2()
		for raw_face_node in raw_element['Nodes']['_arr']:
			center += puzzle.vertices[int(raw_face_node)].pos
		return center / len(raw_element['Nodes']['_arr'])
		

func __match_decorator(raw_decorator, xsi_type):
	if (raw_decorator['xsi:type'] == xsi_type):
		raw_decorator['__consumed'] = true
		return raw_decorator
	if (raw_decorator['xsi:type'] == 'CombinedDecorator'):
		var first = __match_decorator(raw_decorator['First'], xsi_type)
		if (first != null):
			return first
		return __match_decorator(raw_decorator['Second'], xsi_type)
	return null

func __find_decorator(raw_element, xsi_type):
	if ('Decorator' in raw_element):
		var raw_decorator = raw_element['Decorator']
		return __match_decorator(raw_decorator, xsi_type)
	return null

func __check_decorator_consumed(raw_decorator, element_type):
	if (raw_decorator['xsi:type'] == 'CombinedDecorator'):
		__check_decorator_consumed(raw_decorator['First'], element_type)
		__check_decorator_consumed(raw_decorator['Second'], element_type)
	elif (not ('__consumed' in raw_decorator)):
		print('Unsupported decorator: %s on %s' % [raw_decorator['xsi:type'], ['node', 'edge', 'facet'][element_type]])

		
const GRAPH_COUNTER_TEXTS = {'\u250F': 266240, '\u2533': 266241,  '\u2513': 262145,
	'\u2523': 266304, '\u254B': 266305, '\u252B': 262209, 
	'\u2517': 4160, '\u253B': 4161, '\u251B': 65,
	'\u2503': 262208, '\u2501': 4097, '\u254F': 17039424, '\u254D': 16781313 }

func __add_decorator(puzzle, raw_element, v):
	var boxed_decorator = false
	var end_decorator = __find_decorator(raw_element, "EndDecorator")
	if (end_decorator):
		var end_length = float(end_decorator['Length'])
		var end_angle = deg2rad(float(end_decorator['Angle']))
		var p_end = puzzle.vertices[v].pos + Vector2(cos(end_angle), sin(end_angle)) * end_length
		var v_end = push_vertex_vec(puzzle, p_end)
		var e = push_edge_idx(puzzle, v, v_end)
		puzzle.vertices[v_end].is_attractor = true
		puzzle.vertices[v].is_attractor = true
		puzzle.vertices[v_end].is_puzzle_end = true
	if (__find_decorator(raw_element, "BoxDecorator")):
		boxed_decorator = true
	if (__find_decorator(raw_element, "StartDecorator")):
		puzzle.vertices[v].is_puzzle_start = true
	var text_decorator = __find_decorator(raw_element, "TextDecorator")
	if (text_decorator):
		if (text_decorator['Text'] == 'Obs'):
			var decorator = load('res://script/decorators/obstacle_decorator.gd').new()
			decorator.center = puzzle.vertices[v].pos
			decorator.size = 0.5
			decorator.radius = 1.0
			puzzle.decorators.append(decorator)
		elif (text_decorator['Text'] == '[ ]'):
			boxed_decorator = true
		elif (text_decorator['Text'] == 'X'):
			var decorator = load('res://script/decorators/all_error_decorator.gd').new()
			decorator.color = color(text_decorator['Color'])
			puzzle.vertices[v].decorator = decorator
		elif (text_decorator['Text'] == 'F'):
			var decorator = load('res://script/decorators/filament_decorator.gd').new()
			decorator.color = color(text_decorator['Color'])
			decorator.center = puzzle.vertices[v].pos
			puzzle.vertices[v].decorator = decorator
			var filament_start_decorator = null
			for global_decorator in puzzle.decorators:
				if (global_decorator.rule == 'filament-start'):
					filament_start_decorator = global_decorator
					break
			if (filament_start_decorator == null):
				filament_start_decorator = load('res://script/decorators/filament_start_decorator.gd').new()
				puzzle.decorators.append(filament_start_decorator)
			filament_start_decorator.add_pillar(puzzle.vertices[v].pos)
			decorator.filament_start_decorator = filament_start_decorator
		elif (text_decorator['Text'].to_lower() == 'select 1'):
			puzzle.vertices[v].hidden = true
			puzzle.select_one_subpuzzle = true
		elif (text_decorator['Text'].to_lower() == 'parallel'):
			var p = puzzle.vertices[v].pos
			if (puzzle.symmetry_type != SYMMETRY_PARALLEL):
				puzzle.symmetry_type = SYMMETRY_PARALLEL
				puzzle.n_ways = 1
				puzzle.solution_colors[0] = color(text_decorator['Color'])
				puzzle.symmetry_parallel_points = [p]
			else:
				puzzle.n_ways += 1
				puzzle.symmetry_parallel_points.append(p)
				puzzle.solution_colors.append(color(text_decorator['Color']))
			
		elif (text_decorator['Text'].to_lower() == 'exit'):
			# another way to add an end
			puzzle.vertices[v].is_puzzle_end = true
		elif (text_decorator['Text'].to_lower() == '\u00A4'): # snake
			var snake_manager = null
			for global_decorator in puzzle.decorators:
				if (global_decorator.rule == 'snake-manager'):
					snake_manager = global_decorator
					break
			if (snake_manager == null):
				snake_manager = load('res://script/decorators/snake_manager.gd').new()
				puzzle.decorators.append(snake_manager)
			snake_manager.init_snake_points.append(v)
		elif (text_decorator['Text'].to_lower() == '\u2B6E'): # clockwise arrow
			var decorator = load('res://script/decorators/circle_arrow_decorator.gd').new()
			decorator.color = color(text_decorator['Color'])
			decorator.is_clockwise = true
			puzzle.vertices[v].decorator = decorator
		elif (text_decorator['Text'].to_lower() == '\u2B6F'): # counterclockwise arrow
			var decorator = load('res://script/decorators/circle_arrow_decorator.gd').new()
			decorator.color = color(text_decorator['Color'])
			decorator.is_clockwise = false
			puzzle.vertices[v].decorator = decorator
		elif (text_decorator['Text'].to_lower() == '\u6709\u9650'): # limited water
			var decorator = load('res://script/decorators/limited_water_decorator.gd').new()
			decorator.color = color(text_decorator['Color'])
			puzzle.vertices[v].decorator = decorator
		elif (text_decorator['Text'].to_lower() == '\u6C34'): # water
			var decorator = load('res://script/decorators/water_decorator.gd').new()
			decorator.color = Color.transparent
			puzzle.vertices[v].decorator = decorator
		
		elif (text_decorator['Text'].to_lower() == '\u028A'): # ghost
			var ghost_manager = null
			for global_decorator in puzzle.decorators:
				if (global_decorator.rule == 'ghost-manager'):
					ghost_manager = global_decorator
					break
			if (ghost_manager == null):
				ghost_manager = load('res://script/decorators/ghost_manager.gd').new()
				puzzle.decorators.append(ghost_manager)
			var decorator = load('res://script/decorators/ghost_decorator.gd').new()
			decorator.color = color(text_decorator['Color'])
			decorator.pattern = 0 if float(text_decorator['Angle']) == 0.0 else 1
			puzzle.vertices[v].decorator = decorator
		elif (text_decorator['Text'].to_lower() in ['laser_region_min', 'laser_region_max', '\u263F\uFE0F']): # laser
			var laser_manager = null
			for global_decorator in puzzle.decorators:
				if (global_decorator.rule == 'laser-manager'):
					laser_manager = global_decorator
					break
			if (laser_manager == null):
				laser_manager = load('res://script/decorators/laser_manager.gd').new()
				puzzle.decorators.append(laser_manager)
			if (text_decorator['Text'].to_lower() == 'laser_region_min'):
				laser_manager.min_x = puzzle.vertices[v].pos.x
				laser_manager.min_y = puzzle.vertices[v].pos.y
			elif (text_decorator['Text'].to_lower() == 'laser_region_max'):
				laser_manager.max_x = puzzle.vertices[v].pos.x
				laser_manager.max_y = puzzle.vertices[v].pos.y
			else:
				var decorator = load('res://script/decorators/laser_emitter_decorator.gd').new()
				decorator.color = color(text_decorator['Color'])
				puzzle.vertices[v].decorator = decorator
				decorator.angle = deg2rad(float(text_decorator['Angle']))
				laser_manager.add_laser_emitter(puzzle, puzzle.vertices[v].pos, decorator.color, decorator.angle)
		elif (text_decorator['Text'].to_lower() in ['\uC6C3', '\u337F']): # cosmic express
			var cosmic_manager = null
			for global_decorator in puzzle.decorators:
				if (global_decorator.rule == 'cosmic-manager'):
					cosmic_manager = global_decorator
					break
			if (cosmic_manager == null):
				cosmic_manager = load('res://script/decorators/cosmic_manager.gd').new()
				puzzle.decorators.append(cosmic_manager)
			if (text_decorator['Text'].to_lower() == '\uC6C3'):
				var decorator = load('res://script/decorators/cosmic_alien_decorator.gd').new()
				decorator.color = color(text_decorator['Color'])
				puzzle.vertices[v].decorator = decorator
				cosmic_manager.add_alien(v)
			else:
				var decorator = load('res://script/decorators/cosmic_house_decorator.gd').new()
				decorator.color = color(text_decorator['Color'])
				puzzle.vertices[v].decorator = decorator
				cosmic_manager.add_house(v)
		elif (text_decorator['Text'].to_lower().begins_with('s:')):
			var decorator = load('res://script/decorators/graph_counter_decorator.gd').new()
			decorator.step_x = 1.0 - puzzle.line_width
			decorator.step_y = 1.0 - puzzle.line_width
			decorator.size = 1.0
			decorator.color = color(text_decorator['Color'])
			decorator.angle = deg2rad(float(text_decorator['Angle']))
			decorator.rotational = abs(decorator.angle) > 1e-3
			decorator.matrix = [[int(text_decorator['Text'].substr(2))]]
			puzzle.vertices[v].decorator = decorator
			
		elif (text_decorator['Text'][0] in GRAPH_COUNTER_TEXTS):
			var decorator = load('res://script/decorators/graph_counter_decorator.gd').new()
			var text_matrix = text_decorator['Text'].replace('\r', '').split('\n')
			var n_rows = len(text_matrix)
			var n_cols = 0
			for line in text_matrix:
				n_cols = max(n_cols, len(line))
				var symbols = []
				for chr in line:
					if (chr == ' '):
						symbols.append(0)
					else:
						symbols.append(GRAPH_COUNTER_TEXTS[chr])
				decorator.matrix.append(symbols)
			decorator.step_x = (1.0 - puzzle.line_width) / n_cols
			decorator.step_y = (1.0 - puzzle.line_width) / n_rows
			var font_size = float(text_decorator['SerializableFont']['Size'])
			decorator.size = 1.0 if font_size >= 4.5 else 0.5 if font_size >= 3.5 else 0.34
			decorator.color = color(text_decorator['Color'])
			decorator.angle = deg2rad(float(text_decorator['Angle']))
			decorator.rotational = abs(decorator.angle) > 1e-3
			puzzle.vertices[v].decorator = decorator
			
		elif (text_decorator['Text'].to_lower() in '01234567'):
			var decorator = load('res://script/decorators/minesweeper_decorator.gd').new()
			decorator.color = color(text_decorator['Color'])
			decorator.count = '01234567'.find(text_decorator['Text'].to_lower())
			puzzle.vertices[v].decorator = decorator
		else:
			print('Unknown text decorator %s' % text_decorator['Text'])
	var triangle_decorator = __find_decorator(raw_element, "TriangleDecorator")
	if (triangle_decorator):
		var decorator = load('res://script/decorators/triangle_decorator.gd').new()
		decorator.color = color(triangle_decorator['Color'])
		decorator.count = int(triangle_decorator['Count'])
		puzzle.vertices[v].decorator = decorator
	var arrow_decorator = __find_decorator(raw_element, "ArrowDecorator")
	if (arrow_decorator):
		var decorator = load('res://script/decorators/arrow_decorator.gd').new()
		decorator.color = color(arrow_decorator['Color'])
		decorator.count = int(arrow_decorator['Count'])
		decorator.angle = deg2rad(float(arrow_decorator['Angle']))
		puzzle.vertices[v].decorator = decorator
	var star_decorator = __find_decorator(raw_element, "StarDecorator")
	if (star_decorator):
		var decorator = load('res://script/decorators/star_decorator.gd').new()
		decorator.color = color(star_decorator['Color'])
		puzzle.vertices[v].decorator = decorator
	var square_decorator = __find_decorator(raw_element, "SquareDecorator")
	if (square_decorator):
		var decorator = load('res://script/decorators/square_decorator.gd').new()
		decorator.color = color(square_decorator['Color'])
		puzzle.vertices[v].decorator = decorator
	var circle_decorator = __find_decorator(raw_element, "CircleDecorator")
	if (circle_decorator):
		var decorator = load('res://script/decorators/circle_decorator.gd').new()
		decorator.color = color(circle_decorator['Color'])
		puzzle.vertices[v].decorator = decorator
	var ring_decorator = __find_decorator(raw_element, "RingDecorator")
	if (ring_decorator):
		var decorator = load('res://script/decorators/ring_decorator.gd').new()
		decorator.color = color(ring_decorator['Color'])
		puzzle.vertices[v].decorator = decorator
	var eliminator_decorator = __find_decorator(raw_element, "EliminatorDecorator")
	if (eliminator_decorator):
		if (puzzle.vertices[v].is_puzzle_start):
			var decorator = load('res://script/decorators/all_error_decorator.gd').new()
			decorator.color = color(text_decorator['Color'])
			puzzle.vertices[v].decorator = decorator
		else:
			var decorator = load('res://script/decorators/eliminator_decorator.gd').new()
			decorator.color = color(eliminator_decorator['Color'])
			puzzle.vertices[v].decorator = decorator
	var tetris_decorator = __find_decorator(raw_element, "TetrisDecorator")
	if (tetris_decorator):
		var decorator = __load_tetris(tetris_decorator, false)
		puzzle.vertices[v].decorator = decorator
	var hollow_tetris_decorator = __find_decorator(raw_element, "HollowTetrisDecorator")
	if (hollow_tetris_decorator):
		var decorator = __load_tetris(hollow_tetris_decorator, true)
		puzzle.vertices[v].decorator = decorator
	if (boxed_decorator):
		var decorator = load('res://script/decorators/box_decorator.gd').new()
		decorator.color = Color.black
		decorator.init_vertex = v
		decorator.inner_decorator = puzzle.vertices[v].decorator
		if (decorator.inner_decorator.rule == 'none'):
			decorator.inner_decorator = load('res://script/decorators/heart_decorator.gd').new()
			decorator.inner_decorator.color = Color.pink
		puzzle.decorators.append(decorator)
		puzzle.vertices[v].decorator = load("res://script/decorators/no_decorator.gd").new()
	var point_decorator = __find_decorator(raw_element, "PointDecorator")
	if (point_decorator):
		var extra_scale = float(point_decorator['ExtraScale'])
		if (extra_scale > 1.9):
			puzzle.vertices[v].decorator = load('res://script/decorators/big_point_decorator.gd').new()
		else:
			puzzle.vertices[v].decorator = load('res://script/decorators/point_decorator.gd').new()
		puzzle.vertices[v].decorator.color = color(point_decorator['Color'])
	var self_intersection_decorator = __find_decorator(raw_element, "SelfIntersectionDecorator")
	if (self_intersection_decorator):
		puzzle.vertices[v].decorator = load('res://script/decorators/self_intersection_decorator.gd').new()
		puzzle.vertices[v].decorator.color1 = color(self_intersection_decorator['Color1'])
		puzzle.vertices[v].decorator.color2 = color(self_intersection_decorator['Color2'])
	

func __load_tetris(raw_decorator, is_hollow):
	var shapes = []
	var min_x = INF
	var max_x = -INF
	var min_y = INF
	var max_y = -INF
	for raw_shape in raw_decorator['Shapes']['_arr']:
		var shape = []
		for raw_node in raw_shape['_arr']:
			var node = Vector2(float(raw_node['X']), float(raw_node['Y']))
			min_x = min(min_x, node.x)
			min_y = min(min_y, node.y)
			max_x = max(max_x, node.x)
			max_y = max(max_y, node.y)
			shape.append(node)
		shapes.append(shape)
	var center = Vector2((max_x + min_x) / 2, (max_y + min_y) / 2)
	for shape in shapes:
		for i in range(len(shape)):
			shape[i] -= center
	var decorator = load('res://script/decorators/tetris_decorator.gd').new()
	decorator.shapes = shapes
	decorator.is_hollow = is_hollow
	if (is_hollow):
		decorator.border_size = float(raw_decorator['BorderSize'])
	decorator.color = color(raw_decorator['Color'])
	decorator.margin_size = float(raw_decorator['MarginSize'])
	decorator.angle = deg2rad(float(raw_decorator['Angle']))
	return decorator

func add_element(puzzle, raw_element, element_type, id=-1):
	var symmetry_decorator = __find_decorator(raw_element, "ThreeWayPuzzleDecorator")
	if (symmetry_decorator):
		puzzle.n_ways = 3
		puzzle.symmetry_type = SYMMETRY_ROTATIONAL
		puzzle.symmetry_center = __get_raw_element_center(puzzle, raw_element, element_type, id)
		puzzle.symmetry_center += Vector2(float(symmetry_decorator['DeltaX']), float(symmetry_decorator['DeltaY']))
		puzzle.solution_colors.push_back(color(symmetry_decorator['SecondLineColor']))
		puzzle.solution_colors.push_back(color(symmetry_decorator['ThirdLineColor']))
	symmetry_decorator = __find_decorator(raw_element, "SymmetryPuzzleDecorator")
	if (symmetry_decorator):
		var is_rotational = symmetry_decorator['IsRotational']
		assert(is_rotational in ['true', 'false'])
		puzzle.n_ways = 2
		puzzle.symmetry_type = SYMMETRY_ROTATIONAL if is_rotational == 'true' else SYMMETRY_REFLECTIVE
		puzzle.symmetry_center = __get_raw_element_center(puzzle, raw_element, element_type, id)
		puzzle.symmetry_center += Vector2(float(symmetry_decorator['DeltaX']), float(symmetry_decorator['DeltaY']))
		var symmetry_angle = deg2rad(float(symmetry_decorator['Angle']))
		puzzle.symmetry_normal = Vector2(-sin(symmetry_angle), cos(symmetry_angle))
		puzzle.solution_colors.push_back(color(symmetry_decorator['SecondLineColor']))
	symmetry_decorator = __find_decorator(raw_element, "ParallelPuzzleDecorator")
	if (symmetry_decorator):
		puzzle.n_ways = 2
		puzzle.symmetry_type = SYMMETRY_PARALLEL
		var p1 = __get_raw_element_center(puzzle, raw_element, element_type, id)
		p1 += Vector2(float(symmetry_decorator['DeltaX']), float(symmetry_decorator['DeltaY']))
		var p2 = p1 + Vector2(float(symmetry_decorator['TranslationX']), float(symmetry_decorator['TranslationY']))
		puzzle.symmetry_parallel_points = [p1, p2]
		puzzle.solution_colors.push_back(color(symmetry_decorator['SecondLineColor']))
	if (element_type == EDGE_ELEMENT):
		var v1 = int(raw_element['Start'])
		var v2 = int(raw_element['End'])
		if (v1 == v2): # edges due to a bug in level editor
			return
		var p1 = puzzle.vertices[v1].pos
		var p2 = puzzle.vertices[v2].pos
		var v_mid
		v_mid = push_vertex_vec(puzzle, p1 * 0.5 + p2 * 0.5)
		puzzle.vertices[v_mid].linked_edge_tuple = [v1, v2]
		var e1 = push_edge_idx(puzzle, v1, v_mid)
		var e2 = push_edge_idx(puzzle, v2, v_mid)
		__add_decorator(puzzle, raw_element, v_mid)
		
		if (__find_decorator(raw_element, "BrokenDecorator")):
			puzzle.vertices[v_mid].decorator = load('res://script/decorators/broken_decorator.gd').new()
			puzzle.vertices[v_mid].decorator.direction = (p2 - p1) * (0.25 - puzzle.line_width / (2 * p2.distance_to(p1)))
		puzzle.edge_detector_node[[v1, v2]] = v_mid
		puzzle.edge_detector_node[[v2, v1]] = v_mid
		puzzle.edge_shared_facets[[v1, v2]] = []
		puzzle.edge_shared_facets[[v2, v1]] = []
	elif (element_type == FACET_ELEMENT):
		var facet_vertices = []
		var facet_vertex_indices = []
		var edge_tuples = []
		for raw_face_node in raw_element['Nodes']['_arr']:
			facet_vertex_indices.push_back(int(raw_face_node))
			facet_vertices.push_back(puzzle.vertices[int(raw_face_node)])
		if (len(facet_vertex_indices) > 0):
			facet_vertex_indices.push_back(facet_vertex_indices[0])
		for i in range(len(facet_vertices)):
			var edge_tuple = [facet_vertex_indices[i], facet_vertex_indices[i + 1]]
			if (not (edge_tuple in puzzle.edge_shared_facets)):
				print('Warning: facet %d missing an edge %d - %d' % [len(puzzle.facets), edge_tuple[0], edge_tuple[1]])
			else:
				puzzle.edge_shared_facets[[facet_vertex_indices[i], facet_vertex_indices[i + 1]]].append(len(puzzle.facets))
				puzzle.edge_shared_facets[[facet_vertex_indices[i + 1], facet_vertex_indices[i]]].append(len(puzzle.facets))
			edge_tuples.push_back(edge_tuple)
		var facet = Facet.new(facet_vertices)
		facet.edge_tuples = edge_tuples
		var v_f = push_vertex_vec(puzzle, facet.center, true)
		facet.center_vertex_index = v_f
		__add_decorator(puzzle, raw_element, facet.center_vertex_index)
		facet.index = len(puzzle.facets)
		puzzle.vertices[v_f].linked_facet = facet
		puzzle.facets.push_back(facet)
	if (element_type == VERTEX_ELEMENT):
		__add_decorator(puzzle, raw_element, id)
	if ('Decorator' in raw_element):
		var raw_decorator = raw_element['Decorator']
		__check_decorator_consumed(raw_decorator, element_type)
	
func load_from_xml(file, preview_only=false):
	if ('<' in file and '>' in file):
		var pos1 = file.find('<')
		var pos2 = file.find('>')
		file = file.substr(0, pos1) + file.substr(pos2 + 1)
	var puzzle = Puzzle.new()
	puzzle.n_ways = 1
	var raw = better_xml.parse_xml_file(file)
	var raw_meta = raw['MetaData']
	# print(raw_meta['LineColor'])
	puzzle.solution_colors = [color(raw_meta['LineColor'])]
	puzzle.line_color = color(raw_meta['ForegroundColor'])
	puzzle.background_color = color(raw_meta['BackgroundColor'])
	puzzle.line_width = float(raw_meta['EdgeWidth'])
	puzzle.start_size = puzzle.line_width * 1.5
	var vertices = puzzle.vertices
	var edges = puzzle.edges
	var facets = puzzle.facets
	for raw_node in raw['Nodes']['_arr']:
		var v = push_vertex_vec(puzzle, Vector2(float(raw_node['X']), float(raw_node['Y'])), raw_node['Hidden'] == 'true')
		puzzle.vertices[v].is_attractor = true
	for i in range(len(raw['Nodes']['_arr'])):
		var raw_node = raw['Nodes']['_arr'][i]
		add_element(puzzle, raw_node, VERTEX_ELEMENT, i)
	for raw_edge in raw['EdgesID']['_arr']:
		add_element(puzzle, raw_edge, EDGE_ELEMENT)
	for raw_face in raw['FacesID']['_arr']:
		add_element(puzzle, raw_face, FACET_ELEMENT)
	if (not preview_only):
		puzzle.preprocess_tetris_covering()
		puzzle.preprocess_edge_angles()
		puzzle.build_neighbor_graph()
	return puzzle
	
	
