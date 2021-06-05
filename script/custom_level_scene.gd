extends Node2D

onready var info_text = $TextureRect/RichTextLabel2

# Declare member variables here. Examples:
# var a = 2
# var b = "text"



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_files_dropped(files, screen):
	if (len(files) > 0):
		var file = files[0]
		if (file.to_lower().ends_with('.wit')):
			info_text.bbcode_text = '[center]Loading %s ...[/center]' % file
			Gameplay.load_custom_level(file)
		else:
			info_text.bbcode_text = '[center]Please drag a file with extension *.wit![/center]'
			



func _on_back_button_pressed():
	get_tree().change_scene("res://menu_main.tscn")
