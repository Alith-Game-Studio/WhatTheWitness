extends Node2D

onready var seed_text = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/SeedText
onready var set_buttons = $MarginContainer/VBoxContainer/HBoxContainer/SetButtons
onready var description_box = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/DescriptionBox
onready var menu_bar_button = $MenuBarButton
const LEVEL_SETS = {
	'Challenge: Normal': ['challenge_levels.tscn', """比原版见证者留声机稍微难一点的挑战关卡。暂时没有反毛方和抗体。
""", 2],
	'Challenge: Misc': ['challenge_levels_misc.tscn', """一些还没整理的杂项关卡
""", 3],
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
	else:
		Gameplay.challenge_mode = false
	Gameplay.challenge_set_name = set_name
	Gameplay.level_set = LEVEL_SETS[set_name][0]
	Gameplay.total_challenge_music_tracks = LEVEL_SETS[set_name][2]
	
	get_tree().change_scene("res://level_map.tscn")
		

func hover_set(set_name: String):
	if !(set_name in LEVEL_SETS):
		description_box.text = '???'
	else:
		description_box.text = LEVEL_SETS[set_name][1]
		
		
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

