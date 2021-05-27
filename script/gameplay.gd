extends Node

const PUZZLE_FOLDER = 'res://puzzles/'
var puzzle_name = ""

var puzzle: Graph.Puzzle
var solution: Solution.SolutionLine
var canvas: Visualizer.PuzzleCanvas
var validator: Validation.Validator
var validation_elasped_time: float
var background_texture = null

func get_absolute_puzzle_path():
	return PUZZLE_FOLDER + puzzle_name
