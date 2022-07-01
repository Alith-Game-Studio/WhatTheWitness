extends Node2D

onready var seed_text = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/SeedText
onready var set_buttons = $MarginContainer/VBoxContainer/HBoxContainer/ScrollContainer/SetButtons
onready var description_box = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/DescriptionBox
onready var menu_bar_button = $MenuBarButton

func sample_seed():
	seed_text.text = str(randi())


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
