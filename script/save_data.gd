extends Node

var saved_solutions = {}
const SAVE_PATH = "user://savegame.save"

func puzzle_solved(puzzle_name):
	return puzzle_name in saved_solutions

func update(puzzle_name: String, solution_string: String):
	saved_solutions[puzzle_name] = solution_string
	if !(('$' + puzzle_name) in saved_solutions):
		var time = OS.get_datetime()
		saved_solutions['$' + puzzle_name] = '%04d%02d%02d.%02d:%02d:%02d' % [
			time.year, time.month, time.day, time.hour, time.minute, time.second]
	save_all()

func save_all():
	var save_game = File.new()
	save_game.open(SAVE_PATH, File.WRITE)
	if ('&checksum' in saved_solutions):
		saved_solutions.erase('&checksum')
	var line = to_json(saved_solutions)
	# var checksum = (line + 'ArZgL!.zVx-.').md5_text()
	# line = ('{"&checksum":"%s",' % checksum) + line.substr(1)
	save_game.store_line(line)
	save_game.close()
	
func load_all():
	var save_game = File.new()
	if not save_game.file_exists(SAVE_PATH):
		saved_solutions = {}
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

func get_setting():
	load_all()
	var setting = {}
	if ('&setting' in saved_solutions):
		setting = saved_solutions['&setting']
	return setting
	
func save_setting(setting):
	saved_solutions['&setting'] = setting
	save_all()
