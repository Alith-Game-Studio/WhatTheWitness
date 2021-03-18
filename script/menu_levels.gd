extends Node2D

const puzzle_dir = "res://puzzles"
var puzzle_preview_prefab = preload("res://PuzzlePreview.tscn")

func list_files(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if (file == ''):
			return files
		if (file == '.' or file == '..'):
			continue
		files.append(file)
		
	
	
func _ready():
	var grid = $MarginContainer/VBoxContainer/ScrollContainer/GridContainer
	var puzzle_files = list_files(puzzle_dir)
	var i = 0
	for puzzle_file in puzzle_files:
		var target = puzzle_preview_prefab.instance()
		grid.add_child(target)
		target.show_puzzle(puzzle_dir + '/' + puzzle_file)
