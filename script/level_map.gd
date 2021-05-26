extends Node2D

const puzzle_dir = "res://puzzles"
onready var puzzle_placeholders = $View/PuzzlePlaceHolders.get_children()
onready var view = $View
onready var view_origin = -get_viewport().size / 2
onready var drag_start = null
var view_scale = 1.0
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
	$View/PuzzlePlaceHolders.hide()
	var puzzle_files = list_files(puzzle_dir)
	var files = list_files(puzzle_dir)
	var viewports = []
	for placeholder in puzzle_placeholders:
		var puzzle_file = placeholder.text.to_lower() + '.wit'
		if (puzzle_file in files):
			var target = MenuData.puzzle_preview_prefab.instance()
			view.add_child(target)
			target.set_position(placeholder.get_position())
			target.show_puzzle(puzzle_file)
			placeholder.get_parent().remove_child(placeholder)

func update_view():
	var window_size = get_viewport().size
	view.position = window_size / 2 + (view_origin) * view_scale
	view.scale = Vector2(view_scale, view_scale)

func _input(event):
	if (event is InputEventMouseButton):
		if (event.button_index == BUTTON_WHEEL_DOWN):
			view_scale *= 0.8
		elif (event.button_index == BUTTON_WHEEL_UP):
			view_scale *= 1.25
		elif (event.pressed):
			drag_start = event.position
		else:
			drag_start = null
			return
	elif (event is InputEventMouseMotion):
		if (drag_start != null):
			view_origin += (event.position - drag_start) / view_scale
			drag_start = event.position
	update_view()
	
