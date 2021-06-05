extends Node

const PUZZLE_FOLDER = 'res://puzzles/'
var puzzle_name = ""

var playing_custom_puzzle: bool
var puzzle_path: String
var puzzle: Graph.Puzzle
var solution: Solution.SolutionLine
var canvas: Visualizer.PuzzleCanvas
var validator: Validation.Validator
var validation_elasped_time: float
var background_texture = null
var loaded_from_command_line: bool

func get_absolute_puzzle_path():
	return PUZZLE_FOLDER + puzzle_name


func load_custom_level(level_path):
	get_tree().change_scene("res://main.tscn")
	puzzle_path = level_path
	playing_custom_puzzle = true
		

func drag_custom_levels(files, screen):
	if (len(files) > 0):
		var file = files[0]
		if (file.to_lower().ends_with('.wit')):
			Gameplay.load_custom_level(file)
