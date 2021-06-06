extends "../decorator.gd"

var rule = 'ghost-manager'
const GHOST_COLOR_INTERP_START = 0.2


func draw_below_solution(canvas, owner, owner_type, puzzle, solution):
	var id = owner
	if (solution == null or !solution.started or len(solution.state_stack[-1].event_properties) <= id):
		return
	var state = solution.state_stack[-1]
	var vertex_ghost_property = state.event_properties[id]
	var main_way = Solution.MAIN_WAY
	var vertices_main_way = state.vertices[main_way]
	for layer in range(3):
		for way in range(puzzle.n_ways):
			if (way >= len(state.vertices)):
				continue
			if (len(state.solution_stage) <= way or state.solution_stage[way] != Solution.SOLUTION_STAGE_GHOST):
				continue
			var vertices_way = state.vertices[way]
			var color = puzzle.solution_colors[way]
			if (solution.validity == -1):
				color = Color.black
			elif (solution.validity == 0): # drawing illumination
				color = Color(1 - (1 - color.r) * 0.6, 1 - (1 - color.g) * 0.6, 1 - (1 - color.b) * 0.6, color.a)
			var delta_shift = Vector2.ZERO
			var last_pos = puzzle.vertices[vertices_way[0]].pos
			if (len(state.solution_stage) > way and state.solution_stage[way] == Solution.SOLUTION_STAGE_SNAKE):
				if (len(vertices_way) > 1 and !puzzle.vertices[vertices_way[-1]].is_puzzle_end):
					last_pos = last_pos * (1 - solution.progress) + puzzle.vertices[vertices_way[1]].pos * solution.progress
			canvas.add_circle(last_pos, puzzle.start_size, color)
			var last_point_ghosted = false
			var line_color = puzzle.line_color
			var ghosted_color = Color(color.r * 0.1 + line_color.r * 0.9, color.g * 0.1 + line_color.g * 0.9, color.b * 0.1 + line_color.b * 0.9)
			for i in range(1, len(vertices_way)):
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
				var point_ghosted = is_solution_point_ghosted(vertex_ghost_property, way, i)
				if (int(point_ghosted) + int(last_point_ghosted) == 2 - layer):
					if (last_pos != null):
						var point_color = ghosted_color if point_ghosted else color
						var prev_point_color = ghosted_color if last_point_ghosted else color
						if (percentage < 1 - GHOST_COLOR_INTERP_START):
							var t = max(0, (percentage - GHOST_COLOR_INTERP_START) / (1 - 2 * GHOST_COLOR_INTERP_START))
							point_color = Color(point_color.r * t + prev_point_color.r * (1 - t),
								point_color.g * t + prev_point_color.g * (1 - t),
								point_color.b * t + prev_point_color.b * (1 - t))

						var t1 = min(percentage, GHOST_COLOR_INTERP_START) / percentage
						var t2 = min(percentage, 1 - GHOST_COLOR_INTERP_START) / percentage
						canvas.add_circle(pos, puzzle.line_width / 2.0, point_color)
						canvas.add_gradient_lines(
							[last_pos, last_pos * (1 - t1) + pos * t1,
							last_pos * (1 - t2) + pos * t2, pos],
							puzzle.line_width, [prev_point_color, prev_point_color, point_color, point_color])
				last_pos = pos
				last_point_ghosted = point_ghosted
			if (layer == 2):
				if (solution.validity == 0): # drawing
					canvas.add_circle(last_pos, puzzle.line_width / 2.7, line_color)
					canvas.add_circle(last_pos, puzzle.line_width / 3.1, color)
func is_solution_point_ghosted(vertex_ghost_property, way, id):
	if (len(vertex_ghost_property) <= way):
		return false
	var way_ghost_points = vertex_ghost_property[way]
	var phase = 0 if len(way_ghost_points) == 0 else abs(way_ghost_points[0]) - 1
	for i in range(len(way_ghost_points) + 1):
		var prev_pos = 0 if (i == 0) else way_ghost_points[i - 1]
		var next_pos = way_ghost_points[i] if (i < len(way_ghost_points)) else id + 1 # INF
		if (id <= abs(next_pos) - 1):
			if (prev_pos > 0): # pattern = 0, or equivalently cycle 100011
				return (id - phase) % 6 in [1, 2, 3]
			elif (prev_pos < 0): # pattern = 1, or equivalently cycle 000010
				return (id - phase) % 6 != 5
			else: # normal line, not ghosted
				return false
				
func init_property(puzzle, solution_state, start_vertex):
	solution_state.solution_stage.clear()
	for way in range(puzzle.n_ways):
		solution_state.solution_stage.append(Solution.SOLUTION_STAGE_GHOST)
	var vertex_ghost_property = []
	for way in range(puzzle.n_ways):
		vertex_ghost_property.append([])
	return vertex_ghost_property

func property_to_string(vertex_ghost_property):
	var ghost_result = []
	for way_property in vertex_ghost_property:
		var way_result = []
		for v in way_property:
			way_result.append(str(v))
		ghost_result.append(PoolStringArray(way_result).join(','))
	return PoolStringArray(ghost_result).join('|')

func string_to_property(string):
	var ghost_result = string.split('|')
	var vertex_ghost_property = []
	for way_result in ghost_result:
		var way_property = []
		var v_result = way_result.split(',')
		for v_string in v_result:
			way_property.append(int(v_string))
		vertex_ghost_property.append(way_property)
	return vertex_ghost_property

func post_load_state(puzzle, solution_state):
	solution_state.solution_stage.clear()
	for way in range(puzzle.n_ways):
		solution_state.solution_stage.append(Solution.SOLUTION_STAGE_GHOST)
	
