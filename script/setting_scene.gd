extends Node2D
onready var clear_save_button = $MarginContainer/VBoxContainer/ClearProgressButton
onready var mouse_speed_text = $MarginContainer/VBoxContainer/HBoxContainer2/VBoxContainer/MouseSpeedText
onready var mouse_speed_slider = $MarginContainer/VBoxContainer/HBoxContainer2/VBoxContainer/MouseSpeedSlider
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var setting = SaveData.get_setting()
	if ('mouse_speed' in setting):
		mouse_speed_slider.value = setting['mouse_speed']
		


func _on_BackButton_pressed():
	get_tree().change_scene("res://menu_main.tscn")


func _on_ImportSaveButton_pressed():
	get_tree().change_scene("res://import_save_scene.tscn")


func _on_ExportSaveButton_pressed():
	get_tree().change_scene("res://export_save_scene.tscn")


func _on_ClearProgressButton_pressed():
	if (clear_save_button.text == 'Are you sure?'):
		SaveData.clear()
		clear_save_button.text = 'Save cleared.'
		if (MenuData.puzzle_preview_panels != null):
			for puzzle_name in MenuData.puzzle_preview_panels:
				if (MenuData.puzzle_preview_panels[puzzle_name] != null):
					MenuData.puzzle_preview_panels[puzzle_name].update_puzzle(false)
	else:
		clear_save_button.text = 'Are you sure?'


func _on_MouseSpeedSlider_value_changed(value):
	var new_speed = exp(mouse_speed_slider.value)
	mouse_speed_text.bbcode_text = '[center]%.2f[/center]' % new_speed
	var setting = SaveData.get_setting()
	setting['mouse_speed'] = mouse_speed_slider.value
	SaveData.save_setting(setting)



func _on_CustomMusicButton_pressed():
	get_tree().change_scene("res://custom_music_scene.tscn")
