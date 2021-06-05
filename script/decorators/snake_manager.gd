extends "../decorator.gd"

var rule = 'snake-manager'
var init_snake_points: Array


func __draw_snake_point(canvas, puzzle, vertex):
	canvas.add_circle(vertex.pos, puzzle.line_width * 1.0, puzzle.line_color)
	for i in range(4):
		var angle = PI / 2 * i + PI / 4
		canvas.add_line(vertex.pos, vertex.pos + 0.3 * Vector2(cos(angle), sin(angle)), puzzle.line_width * 0.2, puzzle.line_color)

func draw_below_solution(canvas, owner, owner_type, puzzle, solution):
	var id = owner
	var snake_points
	if (solution == null or !solution.started or len(solution.state_stack[-1].event_properties) <= id):
		snake_points = init_snake_points
	else:
		snake_points = solution.state_stack[-1].event_properties[id] 
	for v in snake_points:
		__draw_snake_point(canvas, puzzle, puzzle.vertices[v])

func init_property(puzzle, solution_state, start_vertex):
	return init_snake_points

func property_to_string(snake_points):
	var snake_result = []
	for snake_v in snake_points:
		snake_result.append(str(snake_v))
	return PoolStringArray(snake_result).join(',')

func string_to_property(string):
	if (string != ''):
		var snake_result = string.split(',')
		var snake_points = []
		for snake_string in snake_result:
			snake_points.append(int(snake_string))
		return snake_points
	return []
