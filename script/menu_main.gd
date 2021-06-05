extends Node2D

onready var clear_save_button = $MarginContainer/VBoxContainer/ClearProgressButton

func _on_start_button_pressed():
	get_tree().change_scene("res://level_map.tscn")


func _on_reset_progress_button_pressed():
	if (clear_save_button.text == 'Are you sure?'):
		SaveData.clear()
		clear_save_button.text = 'Save cleared.'
		for puzzle_name in MenuData.puzzle_preview_panels:
			MenuData.puzzle_preview_panels[puzzle_name].update_puzzle(false)
	else:
		clear_save_button.text = 'Are you sure?'

func _ready():
	CSPHelper.initialize()
	get_tree().connect("files_dropped", Gameplay, "drag_custom_levels")
	if (!Gameplay.loaded_from_command_line):
		var args = OS.get_cmdline_args()
		Gameplay.drag_custom_levels(args, null)
		Gameplay.loaded_from_command_line = true


func _on_export_save_button_pressed():
	get_tree().change_scene("res://export_save_scene.tscn")

func _on_import_save_button_pressed():
	get_tree().change_scene("res://import_save_scene.tscn")

func _on_custom_level_button_pressed():
	get_tree().change_scene("res://custom_level_scene.tscn")
