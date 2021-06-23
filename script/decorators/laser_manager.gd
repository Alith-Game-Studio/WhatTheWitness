extends "../decorator.gd"

var rule = 'laser-manager'

var n_laser = 0
var init_lasers = []
var laser_colors = []
const INF_FAR = 9999.99
const MAX_REFLECTION = 512
const MIN_COLLISION_DIST = 5e-2
const LASER_EMITTER_OBS_RADIUS = 1e-2

func draw_below_solution(canvas: Visualizer.PuzzleCanvas, owner, owner_type, puzzle, solution):
	var id = owner
	var lasers
	if (solution == null or !solution.started or len(solution.state_stack[-1].event_properties) <= id):
		lasers = init_lasers
	else:
		lasers = solution.state_stack[-1].event_properties[id] 
	for k in range(n_laser):
		var color = laser_colors[k]
		var transparent_color = Color(color.r, color.g, color.b, 0.5)
		var laser = lasers[k]
		for i in range(len(laser) - 1):
			var start_pos = laser[i]
			var end_pos = laser[i + 1]
			canvas.add_line(
				start_pos,
				end_pos,
				puzzle.line_width / 4,
				transparent_color)

func laser_reflection(laser, puzzle, solution_state):
	if (len(laser) < 2):
		return
	if (len(laser) >= MAX_REFLECTION):
		return
	var laser_pos = laser[-2]
	var laser_dir = (laser[-1] - laser[-2]).normalized()
	var nearest_collision_pos = null
	var nearest_collision_dist = INF
	var nearest_collision_normal = null
	var collision_is_reflection = true
	for way_vertices in solution_state.vertices:
		for i in range(len(way_vertices) - 1):
			var pos1 = puzzle.vertices[way_vertices[i]].pos
			var pos2 = puzzle.vertices[way_vertices[i + 1]].pos
			var edge_dir = (pos2 - pos1).normalized()
			var intersect = Geometry.segment_intersects_segment_2d(pos1 - edge_dir * 1e-2, pos2 + edge_dir * 1e-2, laser_pos, laser[-1])
			if (intersect != null):
				var collision_dist = intersect.distance_to(laser_pos)
				if (collision_dist > MIN_COLLISION_DIST and collision_dist < nearest_collision_dist):
					nearest_collision_dist = collision_dist
					nearest_collision_pos = intersect
					nearest_collision_normal = edge_dir
					# print('update, ', pos1, pos2, ' vs ', laser_pos, laser_dir, nearest_collision_dist)
	for init_laser in init_lasers:
		var init_laser_center = init_laser[0]
		var dist = Geometry.segment_intersects_circle(laser_pos, laser[-1], init_laser_center, LASER_EMITTER_OBS_RADIUS) * INF_FAR
		if (dist > MIN_COLLISION_DIST and dist < nearest_collision_dist):
			nearest_collision_dist = dist
			nearest_collision_pos = laser_pos + laser_dir * dist
			collision_is_reflection = false
			
	if (nearest_collision_pos != null):
		# print('adopts', nearest_collision_dist)
		laser[-1] = nearest_collision_pos
		if (collision_is_reflection):
			var new_dir = laser_dir.reflect(nearest_collision_normal)
			laser.push_back(nearest_collision_pos + new_dir * INF_FAR)
			return true
	return false

func update_lasers(lasers, puzzle, solution_state):
	for i in range(len(lasers)):
		lasers[i].clear()
		for pos in init_lasers[i]:
			lasers[i].append(pos)
		while(laser_reflection(lasers[i], puzzle, solution_state)):
			pass

func add_laser_emitter(pos, color, angle):
	var id = n_laser
	n_laser += 1
	laser_colors.append(color)
	init_lasers.append([
		pos,
		pos + Vector2(-sin(angle), cos(angle)) * INF_FAR
	])

func init_property(puzzle, solution_state, start_vertex):
	return init_lasers

func vector_to_string(vec):
	return '%.2f/%.2f' % [vec.x, vec.y]

func string_to_vector(string):
	var split_string = string.split('/')
	if (len(split_string) == 2):
		return Vector2(float(split_string[0]), float(split_string[1]))
	else:
		return Vector2.ZERO

func property_to_string(lasers):
	var lasers_result = []
	if (lasers != null):
		for laser in lasers:
			var laser_result = []
			for pos in laser:
				laser_result.append(vector_to_string(pos))
			lasers_result.append(PoolStringArray(laser_result).join(','))
	return PoolStringArray(lasers_result).join(';')
			
func string_to_property(string):
	var lasers = []
	var lasers_result = string.split(';')
	for laser_string in lasers_result:
		var laser = []
		var laser_result = laser_string.split(',')
		for pos_string in laser_result:
			laser.append(string_to_vector(pos_string))
		lasers.append(laser)
	return lasers
