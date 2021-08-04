extends "../decorator.gd"

var rule = 'cosmic-alien'
const anger_texture = preload("res://img/hand_drawing/anger.png")

func draw_alien(canvas, puzzle, pos, color):
	var circleRadius = 0.2 * (1 - puzzle.line_width)
	var innerRadius = 0.1 * (1 - puzzle.line_width)
	var nb_points = 32
	var points_arc = []
	var angle_point
	points_arc.push_back(pos + Vector2(1, 0) * circleRadius)
	for i in range(nb_points + 1):
		angle_point = 2 * i * PI / nb_points
		points_arc.push_back(pos + Vector2(cos(angle_point), sin(angle_point) - 0.6 * sign(2 * i - nb_points)) * circleRadius)
	for d in [-1.2, 0.8]:
		points_arc.push_back(pos + Vector2(circleRadius, d * innerRadius))
		for i in range(nb_points / 2, nb_points + 1):
			angle_point = -2 * i * PI / nb_points
			points_arc.push_back(pos + Vector2(cos(angle_point), sin(angle_point) + d) * innerRadius)
		points_arc.push_back(pos + Vector2(circleRadius, d * innerRadius))
	canvas.add_polygon(points_arc, color)
	
func draw_anger(canvas, puzzle, pos, color):
	var anger_size = 0.4 * (1 - puzzle.line_width)
	var anger_position = 0.25 * (1 - puzzle.line_width)
	canvas.add_texture(pos + Vector2(anger_position, -anger_position), Vector2(anger_size, anger_size), anger_texture, color)


func draw_foreground(canvas: Visualizer.PuzzleCanvas, owner, owner_type: int, puzzle: Graph.Puzzle):
	draw_alien(canvas, puzzle, Vector2.ZERO, color)
