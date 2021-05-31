extends "../decorator.gd"

var rule = 'filament-start'

var nails: Array

var filament_solution = null
var circleRadius = 0.08

func draw_above_solution(canvas: Visualizer.PuzzleCanvas, owner, owner_type, puzzle, solution):
	if (filament_solution != null):
		var filament_solution_length = len(filament_solution.path_points)
		for i in range(filament_solution_length):
			var end_pos = filament_solution.end_pos if i + 1 == filament_solution_length else filament_solution.path_points[i + 1][0]
			canvas.add_line(
				filament_solution.path_points[i][0],
				end_pos,
				puzzle.line_width / 4,
				Color.white)
			canvas.add_circle(end_pos, puzzle.line_width / 8, Color.white)
		var circleRadius = 0.1 * (1 - puzzle.line_width)
		canvas.add_circle(filament_solution.start_pos, circleRadius, Color.black)
		
func add_pillar(pos):
	for i in range(8):
		var angle = i * PI / 4
		nails.append(pos + Vector2(cos(angle), sin(angle)) * circleRadius)

func init_property(puzzle, solution_state, start_vertex):
	filament_solution = Filament.FilamentSolution.new()
	filament_solution.try_start_solution_at(start_vertex.pos)
	return filament_solution

func vector_to_string(vec):
	return '%.2f/%.2f' % [vec.x, vec.y]

func string_to_vector(string):
	var split_string = string.split('/')
	if (len(split_string) == 2):
		return Vector2(float(split_string[0]), float(split_string[1]))
	else:
		return Vector2.ZERO

func property_to_string(filament_solution):
	var point_result = []
	if (filament_solution != null):
		for pos in filament_solution.path_points:
			point_result.append(vector_to_string(pos[0]))
		point_result.append(vector_to_string(filament_solution.end_pos))
	return PoolStringArray(point_result).join(',')

func string_to_property(string):
	filament_solution = Filament.FilamentSolution.new()
	var point_result = string.split(',')
	if (len(point_result) > 1):
		filament_solution.started = true
		for point in point_result:
			filament_solution.path_points.append([string_to_vector(point), -1])
		filament_solution.end_pos = filament_solution.path_points[-1][0]
		filament_solution.path_points.pop_back()
		filament_solution.start_pos = filament_solution.path_points[0][0]
	return filament_solution
