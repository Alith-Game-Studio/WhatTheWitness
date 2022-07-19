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
var challenge_mode: bool
var challenge_start_time: int
var challenge_seed: int = -1
var challenge_total_time: int
var challenge_set_name: String
var level_set: String
var switch_level_set: String
const UNLOCK_ALL_PUZZLES = false

var challenge_music_list = [
	preload('res://audio/music/Peer Gynt Suite no. 1, Op. 46 - I. Morning Mood.mp3'),
	preload('res://audio/music/Peer Gynt Suite no. 1, Op. 46 - II. Aase\'s Death.mp3'),
	preload('res://audio/music/Peer Gynt Suite no. 1, Op. 46 - III. Anitra\'s Dance.mp3'),
	preload('res://audio/music/Peer Gynt Suite no. 1, Op. 46 - IV. In the Hall Of The Mountain King.mp3'),
]
var challenge_music_track = -1
var total_challenge_music_tracks = 2
const LEVEL_SETS = {
	'Challenges': ['levels_challenges.tscn', ''],
	'WitCup 7': ['levels_witcup7.tscn', ''],
	'WitCup 10': ['levels_witcup10.tscn', ''],
	'Other WitCups': ['levels.tscn', ''],
	'Looksy Sets': ['levels_looksy.tscn', ''],
	'Challenge: Speed': ['challenge_levels_easy.tscn', '2:39'],
	'Challenge: Normal': ['challenge_levels.tscn', '6:35'],
	'Challenge: Normal SC': ['challenge_levels.tscn', '6:35'],
	'Challenge: Misc': ['challenge_levels_misc.tscn', '15:00'],
	'Challenge: Eliminators': ['challenge_levels.tscn', '11:09'],
	'Challenge: Rings': ['challenge_levels_ring.tscn', '6:35'],
	'Challenge: Arrows': ['challenge_levels_arrow.tscn', '6:35'],
	'Challenge: Bee Hive': ['challenge_levels_hex.tscn', '6:35'],
	'Challenge: Finite Water': ['challenge_levels.tscn', '11:09'],
	'Challenge: Antipolynomino': ['challenge_levels_arrow.tscn', '6:35'],
	'Challenge: Droplets': ['challenge_levels_arrow.tscn', '6:35'],
	'Challenge: Minesweeper': ['challenge_levels_arrow.tscn', '11:09'],
	'Challenge: Multiple Choices': ['challenge_levels_multiple_choices.tscn', '15:00'],
	'Challenge: What The Witness': ['', '240:00'],
}

func start_challenge():
	challenge_start_time = OS.get_ticks_msec()
	
func get_current_challenge_time():
	if (challenge_start_time <= 0):
		return challenge_start_time
	return OS.get_ticks_msec() - challenge_start_time
	
func get_current_challenge_time_formatted():
	var ms = get_current_challenge_time()
	return '%02d:%02d' % [ms / 60000, (ms / 1000) % 60]

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

func select_set(set_name: String):
	if (LEVEL_SETS[set_name][0] == ''):
		return
	if (set_name.begins_with('Challenge:')):
		if (challenge_seed == -1):
			challenge_seed = int(rand_range(0, 1000000000))
		challenge_mode = true
		var split_time = LEVEL_SETS[set_name][1].split(':')
		var time = int(split_time[0]) * 60 + int(split_time[1])
		challenge_total_time = time
		challenge_set_name = set_name
		total_challenge_music_tracks = 1 if time <= 154 else 2 if time <= 395 else 3 if time <= 669 else 4
	else:
		challenge_mode = false
	level_set = LEVEL_SETS[set_name][0]
	get_tree().change_scene("res://level_map.tscn")

func encode_seed(seed_str: String):
	print(seed_str)
	var is_str = false
	for i in range(len(seed_str)):
		if (seed_str.ord_at(i) < 48 or seed_str.ord_at(i) > 57):
			is_str = true
			break
	if (not is_str):
		return int(seed_str)
	else:
		var result = 0
		for i in range(len(seed_str)):
			result = result * 31 + seed_str.ord_at(i)
		return result

func solution_to_seed(solution, puzzle):
	if (solution != null):
		var solution_str = solution.save_to_string(puzzle)
		var split = solution_str.substr(0, len(solution_str) - 1).split(',')
		var result = 0
		for item in split:
			var v_id = int(item)
			var pos = puzzle.vertices[v_id].pos * 2
			var pos_x = int(pos[0])
			var pos_y = int(pos[1])
			if (pos_y % 2 == 1):
				result += (pos_x / 2 - 1) * pow(10, pos_y / 2 - 1)
		if (len(split) <= 2):
			challenge_seed = -1
		else:
			challenge_seed = int(result)
	else:
		challenge_seed = -1
	var seed_label = $"/root/LevelMap/Menu/View/Tags/SeedLabel"
	if (seed_label != null):
		seed_label.text = tr('SEED') + ': ' + (tr('RANDOM') if challenge_seed == -1 else str(challenge_seed))
							
	

