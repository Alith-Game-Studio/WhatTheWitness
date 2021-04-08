extends "../decorator.gd"

var rule = 'box'
var init_location
var location_stack = []
var box_radius = 0.25

func draw_above_solution(canvas, owner, owner_type, puzzle, solution):
	var inner_radius = box_radius * 0.8
	var location = get_location()
	canvas.add_polygon([
		Vector2(box_radius, box_radius) + location,
		Vector2(box_radius, -box_radius) + location,
		Vector2(-box_radius, -box_radius) + location,
		Vector2(-box_radius, box_radius) + location,
		Vector2(box_radius, box_radius) + location,
		Vector2(inner_radius, inner_radius) + location,
		Vector2(-inner_radius, inner_radius) + location,
		Vector2(-inner_radius, -inner_radius) + location,
		Vector2(inner_radius, -inner_radius) + location,
		Vector2(inner_radius, inner_radius) + location,
	], color)

func get_location():
	if (len(location_stack) == 0):
		return init_location
	else:
		return location_stack[-1]

func collide_test(target_pos):
	var obstacle_position = get_location()
	return (target_pos - obstacle_position).length() <= box_radius
