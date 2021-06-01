extends Node2D
onready var save_text = $TextEdit
func _ready():
	var save_game = File.new()
	if not save_game.file_exists(SaveData.SAVE_PATH):
		save_text = '(no save found!)'
	save_game.open(SaveData.SAVE_PATH, File.READ)
	var line = save_game.get_line()
	save_text.text = line
	save_game.close()


func _on_back_button_pressed():
	get_tree().change_scene("res://menu_main.tscn")
