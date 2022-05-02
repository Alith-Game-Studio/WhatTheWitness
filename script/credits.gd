extends Node


const FULL_AUTHORS = {
	'witness': 'from The Witness',
	'wc1': 'from the 1st WitCup (by Gentova)',
	'wc2': 'from the 2nd WitCup (by Gentova and Zhvsjia)',
	'wc3': 'from the 3rd WitCup (by Fluittene et al.)',
	'wc4': 'from the 4th WitCup (by Artless)',
	'wc5': 'from the 5th WitCup (by Alith)',
	'wc6': 'from the 6th WitCup (by Zhvsjia)',
	'wc7': 'from the 7th WitCup (by Alith)',
	'wc10': 'from the 10th WitCup (by Artless, Leaving Leaves, Zhvsjia, 牙刷架, 普通的解谜人, sevenkplus & Fluittene)',
	'rpg': 'from the Witness RPG Mod (by Sigma144)',
}

func get_full_credit(puzzle_name: String):
	if (puzzle_name.ends_with('.wit')):
		puzzle_name = puzzle_name.substr(0, len(puzzle_name) - 4)
	if (puzzle_name.begins_with('[C]')):
		return 'Challenge puzzle: ' + puzzle_name.substr(3)
	if (!('-' in puzzle_name)):
		return puzzle_name
	else:
		var pos = puzzle_name.find('-')
		var author_abbr = puzzle_name.substr(0, pos)
		var name = puzzle_name.substr(pos + 1)
		if (author_abbr in FULL_AUTHORS):
			return name + ' ' + FULL_AUTHORS[author_abbr]
		return name + ' by ' + author_abbr

