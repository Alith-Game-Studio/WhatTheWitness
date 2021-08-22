extends Node

var puzzle_preview_prefab = preload("res://PuzzlePreview.tscn")

var puzzle_preview_panels = {}
var can_drag_map = true

var puzzle_grid_pos = {}
var grid_pos_puzzle = {}
var puzzle_points = {}

func get_puzzle_on_cell(pos):
	var int_pos = [int(round(pos.x)), int(round(pos.y))]
	if (int_pos in grid_pos_puzzle):
		return grid_pos_puzzle[int_pos]
	return null

func get_unlocked_puzzle_on_cell(pos):
	var int_pos = [int(round(pos.x)), int(round(pos.y))]
	if (int_pos in grid_pos_puzzle):
		if (puzzle_preview_panels[grid_pos_puzzle[int_pos]].puzzle_unlocked):
			return grid_pos_puzzle[int_pos]
	return null
