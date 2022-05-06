extends Node

var saved_solutions = {}
const SAVE_PATH = "user://savegame.save"
const LEGACY_SAVE_PATH = "/Godot/app_userdata/WitCup10/savegame.save"

func puzzle_solved(puzzle_name):
	return puzzle_name in saved_solutions

func update(puzzle_name: String, solution_string: String):
	saved_solutions[puzzle_name] = solution_string
	if !(('$' + puzzle_name) in saved_solutions):
		var time = OS.get_datetime()
		saved_solutions['$' + puzzle_name] = '%04d%02d%02d.%02d:%02d:%02d' % [
			time.year, time.month, time.day, time.hour, time.minute, time.second]
	if (!puzzle_name.begins_with('[C]')):
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
	else:
		save_game.open(SAVE_PATH, File.READ)
		var line = save_game.get_line()
		if (line != ''):
			saved_solutions = parse_json(line)
		save_game.close()
	# load legacy save
	var appdata = OS.get_environment('appdata')
	if (appdata != ''):
		var old_save_path = appdata.replace('\\', '/') + LEGACY_SAVE_PATH
		if save_game.file_exists(old_save_path):
			save_game.open(old_save_path, File.READ)
			var line = save_game.get_line()
			if (line != ''):
				var saved_solutions2 = parse_json(line)
				for solution in saved_solutions2:
					var key = solution
					if ('(' in solution and ')' in solution):  # legacy name fixes.
						key = solution.split('(')[0] + solution.split(')')[1]
					if not (key in saved_solutions):
						saved_solutions[key] = saved_solutions2[solution]
			save_game.close()
			save_all()
			var dir = Directory.new()
			dir.remove(old_save_path)
			save_game.open(old_save_path + '.bak', File.WRITE)
			save_game.store_string(line)
			save_game.close()
	for key in saved_solutions:
		if (key.begins_with('[C]')): # challenge puzzles are not saved
			saved_solutions.erase(key)

func clear():
	var save_game = File.new()
	if save_game.file_exists(SAVE_PATH):
		var dir = Directory.new()
		dir.remove(SAVE_PATH)
	saved_solutions = {}

func get_setting(load_all=true):
	if (load_all):
		load_all()
	var setting = {}
	if ('&setting' in saved_solutions):
		setting = saved_solutions['&setting']
	return setting
	
func save_setting(setting):
	saved_solutions['&setting'] = setting
	save_all()
