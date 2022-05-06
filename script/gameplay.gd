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

var challenge_music_list = [
	preload('res://audio/music/Peer Gynt Suite no. 1, Op. 46 - I. Morning Mood.mp3'),
	preload('res://audio/music/Peer Gynt Suite no. 1, Op. 46 - II. Aase\'s Death.mp3'),
	preload('res://audio/music/Peer Gynt Suite no. 1, Op. 46 - III. Anitra\'s Dance.mp3'),
	preload('res://audio/music/Peer Gynt Suite no. 1, Op. 46 - IV. In the Hall Of The Mountain King.mp3'),
]
var challenge_music_track = -1
var total_challenge_music_tracks = 2

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
