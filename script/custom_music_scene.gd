extends Node2D

onready var item_list = $MarginContainer/VBoxContainer/ItemList
onready var file_dialog = $FileDialog
onready var player = $AudioStreamPlayer
onready var total_time_label = $MarginContainer/VBoxContainer/TotalTimeLabel

var music_list = [
	'Peer Gynt Suite no. 1, Op. 46 - I. Morning Mood.mp3',
	'Peer Gynt Suite no. 1, Op. 46 - II. Aase\'s Death.mp3',
	
]

var temp_track_list = []
# Called when the node enters the scene tree for the first time.
func _ready():
	var settings = SaveData.get_setting()
	if ('track_list' in settings):
		for track in settings['track_list']:
			temp_track_list.append(track)
	update_item_list()
	
func time_to_string(sec):
	var secs = int(round(sec))
	return '%d:%02d' % [int(secs / 60), secs % 60]
	
func update_item_list():
	var total_length = 0.0
	item_list.clear()
	for track in temp_track_list:
		var length = get_audio_length(track)
		total_length += length
		item_list.add_item('%s (%s)' % [track.get_file(), time_to_string(length)])
	total_time_label.text = tr('TOTAL_TIME') + ': ' + time_to_string(total_length)
	

func _on_add_button_pressed():
	file_dialog.popup()

func get_audio_length(path):
	var audio_loader = AudioLoader.new()
	var stream : AudioStream = audio_loader.loadfile(path)
	if (stream == null):
		return 0.0
	var length = stream.get_length()
	return length
	

func _on_file_dialog_files_selected(paths):
	for path in paths:
		item_list.add_item(path)
		var length = get_audio_length(path)
		if (length < 1e-6):
			break
		else:
			temp_track_list.append(path)
	update_item_list()


func _on_item_list_item_selected(index):
	var item = temp_track_list[index]
	if (item == null):
		return
	var audio_loader = AudioLoader.new()
	player.set_stream(audio_loader.loadfile(item))
	player.play()


func _on_back_button_pressed():
	var settings = SaveData.get_setting(false)
	settings['track_list'] = temp_track_list
	SaveData.save_setting(settings)
	get_tree().change_scene("res://menu_main.tscn")


func _on_remove_button_pressed():
	var indices = item_list.get_selected_items()
	if len(indices) > 0:
		var index = indices[0]
		temp_track_list.remove(index)
	update_item_list()


func _on_move_up_button_pressed():
	var indices = item_list.get_selected_items()
	if len(indices) > 0:
		var index = indices[0]
		if (index > 0):
			var tmp = temp_track_list[index]
			temp_track_list[index] = temp_track_list[index - 1]
			temp_track_list[index - 1] = tmp
			tmp = item_list.items[index]
			item_list.move_item(index, index - 1)

func _on_move_down_button_pressed():
	var indices = item_list.get_selected_items()
	if len(indices) > 0:
		var index = indices[0]
		if (index + 1 < len(temp_track_list)):
			var tmp = temp_track_list[index]
			temp_track_list[index] = temp_track_list[index + 1]
			temp_track_list[index + 1] = tmp
			item_list.move_item(index, index + 1)
