extends Node

class FilamentNail:
	var pos: Vector2

class FilamentSolution:
	var started: bool
	var start_pos: Vector2
	var end_pos: Vector2
	var path_points: Array
	
	func try_start_solution_at(pos):
		if (started):
			started = false
			return false
		started = true
		start_pos = pos
		end_pos = pos
		path_points = [[pos, -1]]
		return true

	func det(v1, v2):
		return v1.x * v2.y - v2.x * v1.y
		
	func try_continue_solution(nails, delta):
		if (!started):
			return
		var min_delta_step = delta.length()
		for i in range(len(path_points) - 1):
			var col = Geometry.segment_intersects_segment_2d (path_points[i][0],
				path_points[i + 1][0], end_pos, end_pos + delta)
			if (col != null):
				min_delta_step = min(min_delta_step, (end_pos - col).length())
				print(min_delta_step)
		delta = delta / delta.length() * (min_delta_step - 1e-6)
		if (delta.length() < 1e-6):
			return
		var last_nail_pos = path_points[-1][0]
		var last_bend_direction = path_points[-1][1]
		var second_to_last_nail_pos = start_pos if len(path_points) <= 1 else path_points[-2][0]
		var nearest_collision_forward = INF
		var nearest_collision_far = INF
		var nearest_collision_nail = null
		var nearest_collision_bend_direction = 0
		for target_nail_pos in nails:
			var bend_pos = last_nail_pos
			if (target_nail_pos == last_nail_pos):
				bend_pos = second_to_last_nail_pos
			var nail_vector = target_nail_pos - bend_pos
			var nail_dist = nail_vector.length()
			assert(nail_dist >= 1e-6)
			var nail_dir = nail_vector.normalized()
			var filament_vector = end_pos - bend_pos
			var new_filament_vector = filament_vector + delta
			var old_dot = nail_dir.dot(filament_vector)
			var new_dot = nail_dir.dot(new_filament_vector)
			if (old_dot < nail_dist and new_dot < nail_dist): # todo: fix
				continue
			var old_cross = det(filament_vector, nail_dir)
			var new_cross = det(new_filament_vector, nail_dir)
			var ok = false
			var old_dir
			if (target_nail_pos == last_nail_pos):
				old_dir = last_bend_direction
				if ((old_dir == 0 and new_cross > 0) or
					(old_dir == 1 and new_cross < 0)):
					ok = true
			else:
				old_dir = 0 if old_cross < 0 else 1
				if ((old_dir == 0 and new_cross >= 0) or
					(old_dir == 1 and new_cross <= 0)):
					ok = true
			if (ok):
				var sin_a = abs(old_cross) / filament_vector.length()
				var sin_b = abs(det(delta.normalized(), nail_dir))
				var forward = filament_vector.length() / sin_b * sin_a
				var far = (target_nail_pos - last_nail_pos).length()
				print(forward, ',', far, 'ok')
				if (nearest_collision_forward > forward + 1e-6 or
					(abs(nearest_collision_forward - forward) < 1e-6) and
					far > nearest_collision_far):
					nearest_collision_bend_direction = 1 - old_dir
					nearest_collision_forward = forward
					nearest_collision_far = far
					nearest_collision_nail = target_nail_pos
		if (nearest_collision_nail != null):
			if (nearest_collision_nail == last_nail_pos):
				if (len(path_points) > 1):
					path_points.pop_back()
			else:
				path_points.push_back([nearest_collision_nail, nearest_collision_bend_direction])
		
		if (delta.length() > nearest_collision_forward):
			delta = delta / delta.length() * (nearest_collision_forward + 1e-6)
		end_pos += delta
			
				
			
			
				
			
				
				
