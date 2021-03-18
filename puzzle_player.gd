extends Node2D

var validator = Validation.Validator.new()
var canvas = Visualizer.Canvas.new(self)
var mouse_start_position = null
var is_drawing_solution = false
var puzzle

func _draw():
	canvas.draw_witness()

func _ready():
	canvas.puzzle = Graph.load_from_xml(Gameplay.load_puzzle_path)
	canvas.solution = Solution.SolutionLine.new()
	canvas.normalize_view(get_viewport().size)	

func _physics_process(delta):
	update()

func _input(event):
	if (event is InputEventMouseButton and event.is_pressed()):
		if (is_drawing_solution):
			if (canvas.solution.is_completed()):
				validator.validate(canvas.puzzle, canvas.solution)
			is_drawing_solution = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			if (mouse_start_position != null):
				Input.warp_mouse_position(mouse_start_position)
				mouse_start_position = null
		else:
			if (canvas.solution.try_start_solution_at(canvas.puzzle, canvas.screen_to_world(event.position))):
				validator.reset()
				mouse_start_position = event.position
				is_drawing_solution = true
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if (event is InputEventMouseMotion):
		if (is_drawing_solution):
			var split = 5
			for i in range(split):
				canvas.solution.try_continue_solution(canvas.puzzle, event.relative / canvas.view_scale / split)
	
