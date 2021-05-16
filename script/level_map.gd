extends Node2D

const puzzle_dir = "res://puzzles"
var puzzle_preview_prefab = preload("res://PuzzlePreview.tscn")

func list_files(path):
	var files = {}
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if (file == ''):
			return files
		if (file == '.' or file == '..'):
			continue
		files[file.to_lower()] = true
		
	
	
func _ready():
	var puzzle_placeholders = $PuzzlePlaceHolders.get_children()
	var puzzle_files = list_files(puzzle_dir)
	var files = list_files(puzzle_dir)
	for placeholder in puzzle_placeholders:
		print(placeholder.text)
		var puzzle_file = placeholder.text.to_lower() + '.wit'
		if (puzzle_file in files):
			var target = puzzle_preview_prefab.instance()
			add_child(target)
			target.set_position(placeholder.get_position())
			print(target.get_rect().size)
			target.get_child(0).show_puzzle(puzzle_dir + '/' + puzzle_file)
			placeholder.hide()

