extends Node2D

var mouse_start_position = null
var is_drawing_solution = false
onready var puzzle_drawing_target = $MarginContainer/PuzzleRegion/PuzzleBackground
onready var solver_drawing_target = $MarginContainer/PuzzleRegion/PuzzleForeground
var loaded = false
func load_puzzle():
	Gameplay.puzzle = Graph.load_from_xml(Gameplay.load_puzzle_path)
	Gameplay.solution = Solution.SolutionLine.new()
	Gameplay.validator = null
	Gameplay.canvas = Visualizer.PuzzleCanvas.new()
	Gameplay.canvas.puzzle = Gameplay.puzzle
	Gameplay.puzzle.preprocess_tetris_covering()
	Gameplay.canvas.normalize_view(puzzle_drawing_target.get_rect().size)	
	var back_color = Gameplay.puzzle.background_color
	$ColorRect.color = Color(back_color.r, back_color.g, back_color.b, 0.3)
	puzzle_drawing_target.update()
	loaded = true
	
func _physics_process(delta):
	if (loaded):
		if (Gameplay.validator != null):
			Gameplay.validation_elasped_time += delta
		solver_drawing_target.update()

func _input(event):
	if (loaded):
		if (event is InputEventMouseButton and event.is_pressed()):
			var panel_start_pos = solver_drawing_target.get_global_rect().position
			var position = event.position - panel_start_pos
			if (is_drawing_solution):
				if (Gameplay.solution.is_completed(Gameplay.puzzle)):
					Gameplay.validator = Validation.Validator.new()
					if (Gameplay.validator.validate(Gameplay.puzzle, Gameplay.solution)):
						Gameplay.solution.validity = 1
					else:
						Gameplay.solution.validity = -1
					Gameplay.validation_elasped_time = 0.0
				is_drawing_solution = false
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				if (mouse_start_position != null):
					Input.warp_mouse_position(mouse_start_position + panel_start_pos)
					mouse_start_position = null
			else:
				if (Gameplay.solution.try_start_solution_at(Gameplay.puzzle, Gameplay.canvas.screen_to_world(position))):
					Gameplay.validator = null
					mouse_start_position = position
					is_drawing_solution = true
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		if (event is InputEventMouseMotion):
			if (is_drawing_solution):
				var split = 5
				for i in range(split):
					Gameplay.solution.try_continue_solution(Gameplay.puzzle, event.relative / Gameplay.canvas.view_scale / split)
		if (event is InputEventKey):
			if (event.scancode == KEY_ESCAPE):
				back_to_menu()

func back_to_menu():
	loaded = false
	$"/root/LevelMap/View".show()
	hide()

func _on_back_button_pressed():
	back_to_menu()
