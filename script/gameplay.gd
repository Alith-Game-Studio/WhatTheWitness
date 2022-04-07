extends Node

const PUZZLE_FOLDER = 'res://puzzles/'
var puzzle_name = ""
const ALLOW_CUSTOM_LEVELS = true

var playing_custom_puzzle: bool
var puzzle_path: String
var puzzle: Graph.Puzzle
var solution: Solution.SolutionLine
var canvas: Visualizer.PuzzleCanvas
var validator: Validation.Validator
var validation_elasped_time: float
var background_texture = null
var loaded_from_command_line: bool
var mouse_speed = 1.0

func get_absolute_puzzle_path():
	return PUZZLE_FOLDER + puzzle_name


func load_custom_level(level_path):
	if (ALLOW_CUSTOM_LEVELS):
		get_tree().change_scene("res://main.tscn")
		puzzle_path = level_path
		playing_custom_puzzle = true
		update_mouse_speed()
		

func drag_custom_levels(files, screen):
	if (len(files) > 0):
		var file = files[0]
		if (file.to_lower().ends_with('.wit')):
			Gameplay.load_custom_level(file)

func update_mouse_speed():
	var setting = SaveData.get_setting()
	if ('mouse_speed' in setting):
		mouse_speed = exp(setting['mouse_speed'])
	else:
		mouse_speed = 1.0
