extends Node2D

onready var custom_level_button = $MarginContainer/VBoxContainer/CustomLevelButton

func _on_start_button_pressed():
	Gameplay.challenge_mode = false
	Gameplay.level_set = 'levels.tscn'
	get_tree().change_scene("res://warning_scene.tscn")


func _ready():
	randomize()
	if (!Gameplay.loaded_from_command_line):
		var args = OS.get_cmdline_args()
		Gameplay.drag_custom_levels(args, null)
		Gameplay.loaded_from_command_line = true
	if (!Gameplay.ALLOW_CUSTOM_LEVELS):
		custom_level_button.visible = false
	else:
		get_tree().connect("files_dropped", Gameplay, "drag_custom_levels")
	


func _on_custom_level_button_pressed():
	get_tree().change_scene("res://custom_level_scene.tscn")


func _on_CreditsButton_pressed():
	get_tree().change_scene("res://credit_scene.tscn")


func _on_SettingButton_pressed():
	get_tree().change_scene("res://setting_scene.tscn")


func _on_challenge_button_pressed():
	Gameplay.challenge_mode = false
	Gameplay.level_set = 'levels_challenges.tscn'
	get_tree().change_scene("res://warning_scene.tscn")
	
