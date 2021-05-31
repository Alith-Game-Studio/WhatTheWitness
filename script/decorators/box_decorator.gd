extends "../decorator.gd"

var rule = 'box'
var init_vertex
var render_location = null
var location_stack = []
var box_radius = 0.28
var inner_decorator = null

func draw_above_solution(canvas, owner, owner_type, puzzle, solution):
	var id = owner
	var target_location = get_location(puzzle, solution, id)
	if (render_location == null):
		render_location = target_location
	render_location = render_location * 0.8 + target_location * 0.2
	var inner_radius = box_radius * 0.85
	canvas.add_polygon([
		Vector2(inner_radius, inner_radius) + render_location,
		Vector2(-inner_radius, inner_radius) + render_location,
		Vector2(-inner_radius, -inner_radius) + render_location,
		Vector2(inner_radius, -inner_radius) + render_location
	], Color(color.r, color.g, color.b, color.a * 0.5))
	canvas.set_transform(render_location, inner_decorator.angle)
	inner_decorator.draw_foreground(canvas, owner, owner_type, puzzle)
	canvas.set_transform()
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

func init_property(puzzle, solution_state):
	return init_vertex

func get_location(puzzle, solution, id):
	var v
	if (!solution.started or len(solution.state_stack[-1].event_properties) <= id):
		v = init_vertex
	else:
		v = solution.state_stack[-1].event_properties[id] 
	return puzzle.vertices[v].pos
