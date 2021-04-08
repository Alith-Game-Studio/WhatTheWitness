extends "../decorator.gd"

var rule = 'obstacle'

var center : Vector2
var radius : int
var size : float
const texture = preload("res://img/obstacle.png")
var render_angle: float
var target_angle: float

func collide_test(target_pos, solution_length):
	var obstacle_position = get_position(solution_length)
	return (target_pos - obstacle_position).length() <= size / 4

func get_position(solution_length):
	var length = round(solution_length)
	var angle = length * PI / 2
	var position = center + Vector2(cos(angle), sin(angle)) * radius
	return position

func draw_above_solution(canvas, owner, owner_type, puzzle, solution):
	var length = round(solution.get_total_length())
	target_angle = length * PI / 2
	render_angle = render_angle * 0.9 + target_angle * 0.1
	var current_position = center + Vector2(cos(render_angle), sin(render_angle)) * radius
	canvas.add_texture(current_position, Vector2(size, size), texture)
