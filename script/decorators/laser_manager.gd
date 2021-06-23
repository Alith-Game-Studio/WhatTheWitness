extends "../decorator.gd"

var rule = 'laser-manager'

var n_laser = 0
var init_lasers = []
var obstacle_positions = []
var laser_colors = []
const INF_FAR = 9999.99
const MAX_REFLECTION = 512
const LASER_EMITTER_OBS_RADIUS = 0.05
const LASER_EMITTER_RADIUS = 0.1
const CORNER_SIZE = 0.02

func draw_additive_layer(canvas: Visualizer.PuzzleCanvas, owner, owner_type, puzzle, solution):
	var id = owner
	var lasers
	if (solution == null or !solution.started or len(solution.state_stack[-1].event_properties) <= id):
		lasers = init_lasers
	else:
		lasers = solution.state_stack[-1].event_properties[id] 
	for k in range(len(lasers)):
		if (k >= n_laser):
			continue
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
	laser_pos += laser_dir * 1e-6
	var nearest_collision_pos = null
	var nearest_collision_dist = INF
	var nearest_collision_normal = null
	var collision_is_reflection = true
	var last_cut_pos = null
	for way_vertices in solution_state.vertices:
		for i in range(len(way_vertices) - 1):
			var pos1 = puzzle.vertices[way_vertices[i]].pos
			var pos2 = puzzle.vertices[way_vertices[i + 1]].pos
			var edge_dir = (pos2 - pos1).normalized()
			# cut corners
			pos1 += edge_dir * CORNER_SIZE 
			pos2 -= edge_dir * CORNER_SIZE
			if (i + 2 < len(way_vertices)): # line collision
				var intersect = Geometry.segment_intersects_segment_2d(pos1, pos2, laser_pos, laser[-1]) 
				if (intersect != null):
					var collision_dist = intersect.distance_to(laser_pos)
					if (collision_dist >= 0 and collision_dist < nearest_collision_dist):
						nearest_collision_dist = collision_dist
						nearest_collision_pos = intersect
						nearest_collision_normal = edge_dir
			if (last_cut_pos != null): # corners collision
				var corner_intersect = Geometry.segment_intersects_segment_2d(pos1, last_cut_pos, laser_pos, laser[-1]) 
				if (corner_intersect != null):
					var collision_dist = corner_intersect.distance_to(laser_pos)
					if (collision_dist >= 0 and collision_dist < nearest_collision_dist):
						nearest_collision_dist = collision_dist
						nearest_collision_normal = (pos1 - last_cut_pos).normalized()
						var actual_corner = puzzle.vertices[way_vertices[i]].pos
						nearest_collision_pos = actual_corner + (corner_intersect - actual_corner).reflect(Vector2(-nearest_collision_normal.y, nearest_collision_normal.x))
			last_cut_pos = pos2
	for obs_pos in obstacle_positions:
		var dist = Geometry.segment_intersects_circle(laser_pos, laser[-1], obs_pos, LASER_EMITTER_OBS_RADIUS) * INF_FAR
		if (dist > 0 and dist < nearest_collision_dist + 1e-2):
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
	# print(lasers)

func add_laser_emitter(pos, color, angle):
	var id = n_laser
	n_laser += 1
	laser_colors.append(color)
	init_lasers.append([
		pos + Vector2(-sin(angle), cos(angle)) * LASER_EMITTER_RADIUS,
		pos + Vector2(-sin(angle), cos(angle)) * INF_FAR
	])
	obstacle_positions.append(pos)

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
