extends "../decorator.gd"

var rule = 'box'
var init_location
var render_location = null
var location_stack = []
var box_radius = 0.25

func draw_above_solution(canvas, owner, owner_type, puzzle, solution):
	var target_location = get_location()
	if (render_location == null):
		render_location = target_location
	render_location = render_location * 0.8 + target_location * 0.2
	var inner_radius = box_radius * 0.8
	canvas.add_polygon([
		Vector2(box_radius, box_radius) + render_location,
		Vector2(box_radius, -box_radius) + render_location,
		Vector2(-box_radius, -box_radius) + render_location,
		Vector2(-box_radius, box_radius) + render_location,
		Vector2(box_radius, box_radius) + render_location,
		Vector2(inner_radius, inner_radius) + render_location,
		Vector2(-inner_radius, inner_radius) + render_location,
		Vector2(-inner_radius, -inner_radius) + render_location,
		Vector2(inner_radius, -inner_radius) + render_location,
		Vector2(inner_radius, inner_radius) + render_location,
	], color)

func get_location():
	if (len(location_stack) == 0):
		return init_location
	else:
		return location_stack[-1]

func collide_test(target_pos):
	var obstacle_position = get_location()
	return (target_pos - obstacle_position).length() <= box_radius

func push_location(pos):
	var old_target_location = get_location()
	location_stack.append(pos)
	if ((pos - old_target_location).length() > 1e-3):
		render_location = old_target_location

func pop_location():
	var old_target_location = get_location()
	location_stack.pop_back()
	var pos = get_location()
	if ((pos - old_target_location).length() > 1e-3):
		render_location = old_target_location
