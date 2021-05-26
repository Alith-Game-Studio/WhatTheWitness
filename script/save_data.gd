extends Node

var saved_solutions = {}
const SAVE_PATH = "user://savegame.save"

func update(puzzle_name: String, solution_string: String):
	saved_solutions[puzzle_name] = solution_string
	save_all()

func save_all():
	var save_game = File.new()
	save_game.open(SAVE_PATH, File.WRITE)
	var line = to_json(saved_solutions)
	save_game.store_line(line)
	save_game.close()
	
func load_all():
	var save_game = File.new()
	if not save_game.file_exists(SAVE_PATH):
		return 
	save_game.open(SAVE_PATH, File.READ)
	var line = save_game.get_line()
	if (line != ''):
		saved_solutions = parse_json(line)
	save_game.close()

func clear():
	var save_game = File.new()
	if save_game.file_exists(SAVE_PATH):
		var dir = Directory.new()
		dir.remove(SAVE_PATH)
	saved_solutions = {}
