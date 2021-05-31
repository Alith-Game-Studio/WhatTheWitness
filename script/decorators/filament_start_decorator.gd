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
				puzzle.line_width / 5,
				Color.white)
		var circleRadius = 0.1 * (1 - puzzle.line_width)
		canvas.add_circle(filament_solution.start_pos, circleRadius, Color.black)
		
func add_pillar(pos):
	for i in range(8):
		var angle = i * PI / 4
		nails.append(pos + Vector2(cos(angle), sin(angle)) * circleRadius)

func init_property(puzzle, solution_state, start_vertex):
	filament_solution = Filament.FilamentSolution.new()
	filament_solution.try_start_solution_at(start_vertex.pos)
	return null
	
func property_to_string(property):
	return ''

func string_to_property(string):
	return null
