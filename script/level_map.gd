extends Node2D

const puzzle_dir = "res://puzzles"
var puzzle_placeholders
var line_map
var light_map
var gadget_map
var level_area_limit
var view
var light_tile_id
var and_gadget_tile_id
var or_gadget_tile_id
var emitter_gadget_tile_id
onready var extra_menu = $SideMenu/Extra
onready var clear_save_button = $SideMenu/Extra/ClearSaveButton
onready var drag_start = null
onready var puzzle_counter_text = $SideMenu/PuzzleCounter
onready var menu_bar_button = $SideMenu/MenuBarButton
onready var volume_button = $SideMenu/VolumeButton
onready var loading_cover = $LoadingCover
onready var challenge_timer = $ChallengeTimer
onready var music_player = $MusicPlayer
onready var back_button = $FailedCover/BackButton
onready var puzzle_set_label = $SideMenu/PuzzleSetLabel
onready var tween = $MusicPlayer/Tween
var window_size = Vector2(1024, 600)
var view_origin = -window_size / 2
var view_scale = 1.0
var volume = true
var challenge_time_out = false
var challenge_playing_last_music = false
var track_list : Array

const LOADING_BATCH_SIZE = 10

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
		files[file] = true
	
func _ready():
	# loading set
	var set_prefab = load('res://sets/%s' % Gameplay.level_set).instance()
	$Menu.add_child(set_prefab)
	puzzle_placeholders = $Menu/View/PuzzlePlaceHolders
	view = $Menu/View
	level_area_limit = $Menu/View/LevelAreaLimit
	line_map = $Menu/View/Lines
	light_map = $Menu/View/Lights
	gadget_map = $Menu/View/Gadgets
	light_tile_id = light_map.tile_set.find_tile_by_name('light')
	and_gadget_tile_id = gadget_map.tile_set.find_tile_by_name('and_gate')
	or_gadget_tile_id = gadget_map.tile_set.find_tile_by_name('or_gate')
	emitter_gadget_tile_id = gadget_map.tile_set.find_tile_by_name('emitter')
	if (Gameplay.challenge_mode):
		puzzle_set_label.text = '%s (#%d)' % [tr(Gameplay.challenge_set_name), Gameplay.challenge_seed]
		Gameplay.challenge_start_time = 0
	
	# preprocessing
	volume_button.visible = false
	loading_cover.visible = true
	drag_start = null
	# puzzle_placeholders.hide()
	SaveData.load_all()
	var files = list_files(puzzle_dir)
	var viewports = []
	var placeholders = puzzle_placeholders.get_children()
	MenuData.puzzle_grid_pos.clear()
	MenuData.grid_pos_puzzle.clear()
	var pos_points = {}
	var masks_map = {}
	var masks = $Menu/View/Masks
	if masks != null:
		for mask in masks.get_children():
			masks_map[mask.name] = mask
	for placeholder in placeholders:
		if (placeholder.text.begins_with('$')):
			var cell_pos = placeholder.get_position() / 96
			var int_cell_pos = [int(round(cell_pos.x)), int(round(cell_pos.y)) - 1]
			pos_points[int_cell_pos] = int(placeholder.text.substr(1))
			placeholder.get_parent().remove_child(placeholder)
		elif (placeholder.text.begins_with('#')):
			var cell_pos = placeholder.get_position() / 96
			var int_cell_pos = [int(round(cell_pos.x)), int(round(cell_pos.y))]
			var prefix = placeholder.text.substr(1)
			var child_pos = placeholder.get_position() 
			for puzzle_file in files:
				if (puzzle_file.begins_with(prefix)):
					var node = placeholder.duplicate()
					node.text = puzzle_file.substr(0, len(puzzle_file) - 4)
					node.set_position(child_pos)
					placeholder.get_parent().add_child(node)
					var pts_text = puzzle_file.substr(puzzle_file.find('(') + 1)
					pos_points[int_cell_pos] = int(pts_text.substr(0, pts_text.find(')')))
					child_pos += Vector2(96, 0)
					int_cell_pos = [int_cell_pos[0] + 1, int_cell_pos[1]]
			placeholder.get_parent().remove_child(placeholder)
	placeholders = puzzle_placeholders.get_children()
	var processed_placeholder_count = 0
	var total_placeholder_count = 0
	for placeholder in placeholders:
		var puzzle_file = placeholder.text + '.wit'
		if (!placeholder.text.begins_with('$') and (puzzle_file in files or '[?]' in puzzle_file)):
			total_placeholder_count += 1
	for placeholder in placeholders:
		var puzzle_file = placeholder.text + '.wit'
		if (!placeholder.text.begins_with('$') and (puzzle_file in files or '[?]' in puzzle_file)):
			var target = MenuData.puzzle_preview_prefab.instance()
			MenuData.puzzle_preview_panels[puzzle_file] = target
			view.add_child(target)
			target.set_position(placeholder.get_position())
			var cell_pos = target.global_position / 96
			cell_pos = Vector2(round(cell_pos.x), round(cell_pos.y))
			if (puzzle_file in MenuData.puzzle_grid_pos):
				print('[Warning] Duplicated puzzle %s on' % puzzle_file, cell_pos)
			MenuData.puzzle_grid_pos[puzzle_file] = cell_pos
			var int_cell_pos = [int(cell_pos.x), int(cell_pos.y)]
			if (int_cell_pos in MenuData.grid_pos_puzzle):
				print('[Warning] Multiple puzzles (%s) on the same grid position (%d, %d)' % [puzzle_file, cell_pos.x, cell_pos.y])
			MenuData.grid_pos_puzzle[int_cell_pos] = puzzle_file
			MenuData.puzzle_points[puzzle_file] = 0
			if (int_cell_pos in pos_points):
				MenuData.puzzle_points[puzzle_file] = pos_points[int_cell_pos]
			target.points = MenuData.puzzle_points[puzzle_file]
			for mask_name in masks_map:
				if (mask_name in puzzle_file):
					target.linked_solution_texture = masks_map[mask_name]
			target.show_puzzle(puzzle_file, get_light_state(cell_pos))
			placeholder.get_parent().remove_child(placeholder)
			if (Gameplay.challenge_mode):
				Graph.load_from_xml(Gameplay.PUZZLE_FOLDER + puzzle_file, true)
			if (processed_placeholder_count % LOADING_BATCH_SIZE == 0 or Gameplay.challenge_mode):
				puzzle_counter_text.bbcode_text = '[right]%s: %d / %d[/right] ' % [ tr('LOADING_PUZZLE'), processed_placeholder_count, total_placeholder_count]
				yield(VisualServer, "frame_post_draw")
			processed_placeholder_count += 1
	view.move_child(masks, view.get_child_count())
	update_light(true)
	if (Gameplay.challenge_mode):
		volume_button.visible = true
	Gameplay.update_mouse_speed()
	
func get_light_state(pos):
	if (light_map.get_cellv(pos) >= 0):
		return true
	else:
		return false

func update_counter():
	if (Gameplay.challenge_mode):
		puzzle_counter_text.bbcode_text = '[right]%s%s       [/right]' % [Gameplay.get_current_challenge_time_formatted(), ' (' + tr('TIME_OUT') + ')' if challenge_time_out else '']
	else:
		var puzzle_count = 0
		var solved_count = 0
		var score = 0
		var total_score = 0
		for puzzle_file in MenuData.puzzle_grid_pos:
			var pos = MenuData.puzzle_grid_pos[puzzle_file]
			if(SaveData.puzzle_solved(puzzle_file)):
				solved_count += 1
				score += MenuData.puzzle_points[puzzle_file]
			puzzle_count += 1
			total_score += MenuData.puzzle_points[puzzle_file]
		if (total_score > 0):
			puzzle_counter_text.bbcode_text = '[right]%d / %d (%d / %d pts)[/right] ' % [solved_count, puzzle_count, score, total_score]
		else:
			puzzle_counter_text.bbcode_text = '[right]%d / %d[/right] ' % [solved_count, puzzle_count]

func get_gadget_direction(tile_map: TileMap, pos: Vector2):
	var x = int(round(pos.x))
	var y = int(round(pos.y))
	if (tile_map.is_cell_transposed(x, y)):
		return Vector2(0, -1) if tile_map.is_cell_y_flipped(x, y) else Vector2(0, 1)
	else:
		return Vector2(-1, 0) if tile_map.is_cell_x_flipped(x, y) else Vector2(1, 0)

func update_light(first_time=false):
	var stack = []
	for puzzle_file in MenuData.puzzle_grid_pos:
		var pos = MenuData.puzzle_grid_pos[puzzle_file]
		if(SaveData.puzzle_solved(puzzle_file)):
			stack.append(pos)
			light_map.set_cellv(pos, light_tile_id)
			light_map.update_bitmask_area(pos)
	while (!stack.empty()):
		var pos = stack.pop_back()
		# print('Visiting ', pos)
		var deltas = []
		for dir in range(4):
			var delta = Vector2(DIR_X[dir], DIR_Y[dir])
			var new_pos = pos + delta
			if (line_map.get_cellv(new_pos) == -1):
				continue
			deltas.append(delta)
			if (gadget_map.get_cellv(new_pos) == or_gadget_tile_id):
				deltas.append(delta + get_gadget_direction(gadget_map, new_pos))
			if (gadget_map.get_cellv(new_pos) == and_gadget_tile_id):
				var non_activated_neighbor = 0
				for dir2 in range(4):
					var new_pos2 = new_pos + Vector2(DIR_X[dir2], DIR_Y[dir2])
					if (line_map.get_cellv(new_pos2) != -1 and !get_light_state(new_pos2)):
						non_activated_neighbor += 1
				if (non_activated_neighbor == 1):
					deltas.append(delta + get_gadget_direction(gadget_map, new_pos))
			if (gadget_map.get_cellv(new_pos) == emitter_gadget_tile_id):
				if (Gameplay.challenge_mode):
					win_challenge()
		for delta in deltas:
			var new_pos = pos + delta
			if (get_light_state(new_pos)):
				continue
			light_map.set_cellv(new_pos, light_tile_id)
			light_map.update_bitmask_area(new_pos)
			if (gadget_map.get_cellv(new_pos) == -1 and
				MenuData.get_puzzle_on_cell(new_pos) == null):
				stack.append(new_pos)
	var puzzles_to_unlock = []
	for puzzle_file in MenuData.puzzle_grid_pos:
		var pos = MenuData.puzzle_grid_pos[puzzle_file]
		if((Gameplay.UNLOCK_ALL_PUZZLES or get_light_state(pos)) and !MenuData.puzzle_preview_panels[puzzle_file].puzzle_unlocked):
			puzzles_to_unlock.append(puzzle_file)
	var processed_rendering_count = 0
	for puzzle_file in puzzles_to_unlock:
		MenuData.puzzle_preview_panels[puzzle_file].update_puzzle(true)
		if (first_time and processed_rendering_count % LOADING_BATCH_SIZE == 0):
			puzzle_counter_text.bbcode_text = '[right]%s: %d / %d[/right] ' % [tr('RENDERING_PUZZLE'), processed_rendering_count, len(puzzles_to_unlock)]
			yield(VisualServer, "frame_post_draw")
		processed_rendering_count += 1
	if (first_time):
		loading_cover.visible = false
		MenuData.can_drag_map = true
		update_counter()
func update_view():
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
	if (not loading_cover.visible):
		if (event is InputEventMouseButton and MenuData.can_drag_map):
			if (event.button_index == BUTTON_WHEEL_DOWN):
				view_scale = max(view_scale * 0.8, 0.2097152)
			elif (event.button_index == BUTTON_WHEEL_UP):
				view_scale = min(view_scale * 1.25, 3.0)
			elif (event.pressed):
				drag_start = event.position
			else:
				drag_start = null
				return
		elif (event is InputEventMouseMotion):
			if (!MenuData.can_drag_map):
				drag_start = null
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
	get_tree().change_scene("res://menu_main.tscn")


func _on_ChallengeTimer_timeout():
	update_counter()
	var time = Gameplay.get_current_challenge_time() / 1000.0
	if (not challenge_time_out and time > Gameplay.challenge_total_time):
		challenge_time_out = true
		fail_challenge()
	if (not challenge_playing_last_music and Gameplay.challenge_total_time - time < 160):
		var start_value = 0 if volume else -90
		tween.interpolate_property(music_player, "volume_db", start_value, -60, min(5.8, max(0, Gameplay.challenge_total_time - time - 154))) # current music fade out
		tween.start()
		challenge_playing_last_music = true

func _on_tween_tween_completed(object, key):
	music_player.stream = preload('res://audio/music/Peer Gynt Suite no. 1, Op. 46 - IV. In the Hall Of The Mountain King.mp3')
	music_player.volume_db = 0 if volume else -90
	music_player.play()


func _on_music_player_finished():
	if (challenge_playing_last_music): # do not play other music if we are planning to play the last one
		return
	if (challenge_timer.is_stopped()):
		return
	while not track_list.empty():
		var audio_loader = AudioLoader.new()
		var stream = audio_loader.loadfile(track_list[0]) if track_list[0] is String else track_list[0]
		stream.loop = false
		track_list.pop_front()
		if (stream != null and stream.get_length() > 1e-6):
			music_player.stream = stream
			music_player.play()
			return
	
func start_challenge():
	if (challenge_timer.is_stopped()):
		Gameplay.start_challenge()
		challenge_timer.start()
		Gameplay.challenge_music_track = Gameplay.total_challenge_music_tracks
		var settings = SaveData.get_setting(false)
		if ('track_list' in settings and len(settings['track_list']) > 0):
			track_list = [] + settings['track_list']
		else:
			track_list = []
			for i in range(Gameplay.challenge_music_track - 1):
				track_list.append(Gameplay.challenge_music_list[i + 4 - Gameplay.challenge_music_track])
		music_player.stream = preload('res://audio/music/RecorderStart.mp3')
		music_player.play()

func fail_challenge():
	challenge_timer.stop() 
	if ($PuzzleUI.visible):
		$PuzzleUI.disable_drawing()
	puzzle_set_label.text += ". " + tr('TIME_OUT')
	$EndCover.show()
	
func win_challenge():
	puzzle_set_label.text += ". " + tr('YOU_WIN')
	challenge_timer.stop() 
	music_player.stop()
	

func _on_volume_button_pressed():
	volume = !volume
	if (volume):
		music_player.volume_db = 0
		volume_button.texture_normal = preload("res://img/volume.png")
	else:
		music_player.volume_db = -80
		volume_button.texture_normal = preload("res://img/volume_off.png")


func _on_volume_button_mouse_entered():
	volume_button.modulate = Color(volume_button.modulate.r, volume_button.modulate.g, volume_button.modulate.b, 0.5)


func _on_volume_button_mouse_exited():
	volume_button.modulate = Color(volume_button.modulate.r, volume_button.modulate.g, volume_button.modulate.b, 1.0)



func _on_restart_button_pressed():
	get_tree().change_scene("res://level_set_selection_scene.tscn")


func _on_continue_button_pressed():
	challenge_timer.start()
	$EndCover.hide()
	

