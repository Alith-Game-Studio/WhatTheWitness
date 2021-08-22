extends Node2D



func _on_RichTextLabel2_meta_clicked(meta):
	OS.shell_open(meta)


func _on_CreditsButton_pressed():
	get_tree().change_scene("res://menu_main.tscn")
