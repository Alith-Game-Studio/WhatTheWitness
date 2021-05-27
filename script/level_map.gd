extends Node2D

const puzzle_dir = "res://puzzles"
onready var puzzle_placeholders = $Menu/View/PuzzlePlaceHolders
onready var extra_menu = $SideMenu/Extra
onready var clear_save_button = $SideMenu/Extra/ClearSaveButton
onready var view = $Menu/View
onready var view_origin = -get_viewport().size / 2
onready var drag_start = null
onready var level_area_limit = $Menu/View/LevelAreaLimit
onready var line_map = $Menu/View/Lines
onready var light_map = $Menu/View/Lights
onready var light_tile_id = $Menu/View/Lights.tile_set.find_tile_by_name('light')
onready var puzzle_counter_text = $SideMenu/PuzzleCounter
onready var menu_bar_button = $SideMenu/MenuBarButton
var window_size
var view_scale = 1.0

const DIR_X = [-1, 0, 1, 0]
const DIR_Y = [0, -1, 0, 1]

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
	window_size = get_viewport().size
	# puzzle_placeholders.hide()
	SaveData.load_all()
	var puzzle_files = list_files(puzzle_dir)
	var files = list_files(puzzle_dir)
	var viewports = []
	var placeholders = puzzle_placeholders.get_children()
	for placeholder in placeholders:
		var puzzle_file = placeholder.text.to_lower() + '.wit'
		if (puzzle_file in files):
			var target = MenuData.puzzle_preview_prefab.instance()
			MenuData.puzzle_preview_panels[puzzle_file] = target
			view.add_child(target)
			target.set_position(placeholder.get_position())
			var cell_pos = target.global_position / 96
			cell_pos = Vector2(round(cell_pos.x), round(cell_pos.y))
			MenuData.puzzle_grid_pos[puzzle_file] = cell_pos
			MenuData.grid_pos_puzzle[[int(cell_pos.x), int(cell_pos.y)]] = puzzle_file
			target.show_puzzle(puzzle_file, get_light_state(cell_pos))
			placeholder.get_parent().remove_child(placeholder)
	update_light()
	update_counter()

func get_light_state(pos):
	if (light_map.get_cellv(pos) >= 0):
		return true
	else:
		return false

func update_counter():
	var puzzle_count = 0
	var solved_count = 0
	for puzzle_file in MenuData.puzzle_grid_pos:
		var pos = MenuData.puzzle_grid_pos[puzzle_file]
		if(SaveData.puzzle_solved(puzzle_file)):
			solved_count += 1
		puzzle_count += 1
	puzzle_counter_text.bbcode_text = '[right]%d / %d[/right]' % [solved_count, puzzle_count]

func update_light():
	var stack = []
	for puzzle_file in MenuData.puzzle_grid_pos:
		var pos = MenuData.puzzle_grid_pos[puzzle_file]
		if(SaveData.puzzle_solved(puzzle_file)):
			stack.append(pos)
	while (!stack.empty()):
		var pos = stack.pop_back()
		# print('Visiting ', pos)
		for dir in range(4):
			var new_pos = pos + Vector2(DIR_X[dir], DIR_Y[dir])
			if (get_light_state(new_pos)):
				continue
			if (line_map.get_cellv(new_pos) == -1):
				continue
			light_map.set_cellv(new_pos, light_tile_id)
			light_map.update_bitmask_area(new_pos)
			if (MenuData.get_puzzle_on_cell(new_pos) == null):
				stack.append(new_pos)
	for puzzle_file in MenuData.puzzle_grid_pos:
		var pos = MenuData.puzzle_grid_pos[puzzle_file]
		if(get_light_state(pos) and !MenuData.puzzle_preview_panels[puzzle_file].puzzle_unlocked):
			MenuData.puzzle_preview_panels[puzzle_file].update_puzzle(true)

func update_view():
	window_size = get_viewport().size
	view.position = window_size / 2 + (view_origin) * view_scale
	view.scale = Vector2(view_scale, view_scale)
	var limit_pos = level_area_limit.rect_global_position
	var limit_size = level_area_limit.rect_size * view_scale
	var dx = 0.0
	var dy = 0.0
	var extra_margin = 100
	if (limit_pos.x > extra_margin):
		dx += limit_pos.x - extra_margin
	elif (limit_pos.x + limit_size.x < window_size.x - extra_margin):
		dx += limit_pos.x + limit_size.x - window_size.x + extra_margin
	if (limit_pos.y > extra_margin):
		dy += limit_pos.y - extra_margin
	elif (limit_pos.y + limit_size.y < window_size.y - extra_margin):
		dy += limit_pos.y + limit_size.y - window_size.y + extra_margin
	view_origin -= Vector2(dx, dy) / view_scale
	view.position = window_size / 2 + (view_origin) * view_scale
	view.scale = Vector2(view_scale, view_scale)

func _input(event):
	if (event is InputEventMouseButton):
		if (event.button_index == BUTTON_WHEEL_DOWN):
			view_scale = max(view_scale * 0.8, 0.512)
		elif (event.button_index == BUTTON_WHEEL_UP):
			view_scale = min(view_scale * 1.25, 3.0)
		elif (event.pressed):
			if (MenuData.can_drag_map):
				drag_start = event.position
		else:
			drag_start = null
			return
	elif (event is InputEventMouseMotion):
		if (drag_start != null):
			view_origin += (event.position - drag_start) / view_scale
			drag_start = event.position
	update_view()

func _on_clear_save_button_pressed():
	if (clear_save_button.text == 'Are you sure?'):
		SaveData.clear()
		clear_save_button.text = 'Clear Save'
		for puzzle_name in MenuData.puzzle_preview_panels:
			MenuData.puzzle_preview_panels[puzzle_name].update_puzzle(false)
		update_light()
	else:
		clear_save_button.text = 'Are you sure?'
	


func _on_menu_bar_button_mouse_entered():
	menu_bar_button.modulate = Color(menu_bar_button.modulate.r, menu_bar_button.modulate.g, menu_bar_button.modulate.b, 0.5)

func _on_menu_bar_button_mouse_exited():
	menu_bar_button.modulate = Color(menu_bar_button.modulate.r, menu_bar_button.modulate.g, menu_bar_button.modulate.b, 1.0)



func _on_menu_bar_button_pressed():
	extra_menu.visible = !extra_menu.visible
