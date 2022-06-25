extends Node2D

onready var seed_text = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/SeedText
onready var set_buttons = $MarginContainer/VBoxContainer/HBoxContainer/ScrollContainer/SetButtons
onready var description_box = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/DescriptionBox
onready var menu_bar_button = $MenuBarButton
const LEVEL_SETS = {
	'WitCup 7': ['levels_witcup7.tscn', ''],
	'WitCup 10': ['levels_witcup10.tscn', ''],
	'Other WitCups': ['levels.tscn', ''],
	'Looksy Sets': ['levels_looksy.tscn', ''],
	'Challenge: Speed': ['challenge_levels_easy.tscn', '2:34'],
	'Challenge: Normal': ['challenge_levels.tscn', '6:35'],
	'Challenge: Normal SC': ['challenge_levels.tscn', '6:35'],
	'Challenge: Misc': ['challenge_levels_misc.tscn', '14:58'],
	'Challenge: Eliminators': ['challenge_levels.tscn', '11:09'],
	'Challenge: Rings': ['challenge_levels_ring.tscn', '11:09'],
	'Challenge: Arrows': ['challenge_levels_arrow.tscn', '6:35'],
	'Challenge: Bee Hive': ['challenge_levels_hex.tscn', '6:35'],
	'Challenge: Finite Water': ['challenge_levels.tscn', '11:09'],
}

func sample_seed():
	seed_text.text = str(randi())

func encode_seed(seed_str: String):
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

func select_set(set_name: String):
	if (set_name.begins_with('Challenge:')):
		if (seed_text.text == ''):
			sample_seed()
			return
		Gameplay.challenge_seed = encode_seed(seed_text.text)
		Gameplay.challenge_mode = true
		var split_time = LEVEL_SETS[set_name][1].split(':')
		var time = int(split_time[0]) * 60 + int(split_time[1])
		Gameplay.challenge_total_time = time
		Gameplay.challenge_set_name = set_name
		Gameplay.total_challenge_music_tracks = 1 if time <= 154 else 2 if time <= 395 else 3 if time <= 669 else 4
	
	else:
		Gameplay.challenge_mode = false
	Gameplay.level_set = LEVEL_SETS[set_name][0]
	get_tree().change_scene("res://level_map.tscn")
		

func hover_set(set_name: String):
	if !(set_name in LEVEL_SETS):
		description_box.text = '???'
	else:
		description_box.text = tr(set_name + ' DESC').replace('|', '\n\n' + tr('MECHANICS:')) + '\n\n' + tr('TOTAL_TIME') + ': ' + LEVEL_SETS[set_name][1]
		
		
func _ready():
	randomize()
	sample_seed()
	description_box.text = 'Please select a puzzle set.'
	for button in set_buttons.get_children():
		button.connect('pressed', self, 'select_set', [button.text])
		button.connect('mouse_entered', self, 'hover_set', [button.text])

func _on_SeedButton_pressed():
	sample_seed()

func _on_MenuBarButton_pressed():
	get_tree().change_scene("res://menu_main.tscn")
	
func _on_MenuBarButton_mouse_entered():
	menu_bar_button.modulate = Color(menu_bar_button.modulate.r, menu_bar_button.modulate.g, menu_bar_button.modulate.b, 0.5)

func _on_MenuBarButton_mouse_exited():
	menu_bar_button.modulate = Color(menu_bar_button.modulate.r, menu_bar_button.modulate.g, menu_bar_button.modulate.b, 1.0)



func _on_CustomMusicButton_pressed():
	get_tree().change_scene("res://custom_music_scene.tscn")
