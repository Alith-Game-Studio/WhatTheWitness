extends Node2D

const puzzle_dir = "res://puzzles"
var puzzle_preview_prefab = preload("res://PuzzlePreview.tscn")
onready var puzzle_placeholders = $View/PuzzlePlaceHolders.get_children()
onready var view = $View
onready var view_origin = -get_viewport().size / 2
onready var drag_start = null
var view_scale = 1.0
var texture_list = {}
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
	var puzzle_files = list_files(puzzle_dir)
	var files = list_files(puzzle_dir)
	var viewports = []
	for puzzle in files:
		var vport = Viewport.new()
		vport.size = Vector2(256, 256)
		vport.render_target_update_mode = Viewport.UPDATE_ALWAYS 
		# vport.msaa = Viewport.MSAA_4X # useless for 2D
		self.add_child(vport)
		var cvitem = Control.new()
		vport.add_child(cvitem)
		cvitem.rect_min_size = Vector2(256, 256)
		cvitem.name = puzzle.replace('.', '|')
		cvitem.set_script(load("res://script/puzzle_renderer.gd"))
		viewports.append([vport, cvitem])
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	for vport_cvitem in viewports:
		var vport = vport_cvitem[0]
		var cvitem = vport_cvitem[1]
		var vport_img = vport.get_texture().get_data()
		vport_img.flip_y()
		texture_list[cvitem.name.replace('|', '.')] = vport_img
		# vport_img.save_png("res://img/render/%s.png" % cvitem.name.replace('|', '.'))
		remove_child(vport)
		# will the texture be freed?
		vport.queue_free()
	for placeholder in puzzle_placeholders:
		var puzzle_file = placeholder.text.to_lower() + '.wit'
		if (puzzle_file in files):
			var target = puzzle_preview_prefab.instance()
			view.add_child(target)
			target.set_position(placeholder.get_position())
			target.get_child(0).show_puzzle(puzzle_dir + '/' + puzzle_file, texture_list[puzzle_file])
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
	
