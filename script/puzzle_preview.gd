extends ColorRect

var enabled = false
var canvas = Visualizer.PuzzleCanvas.new()
onready var parent = get_node('..')
onready var grandparent = get_node('../..')
var puzzle_path
func _draw():
	if (!enabled):
		return
	canvas.draw_puzzle(self)
		
func show_puzzle(path):
	puzzle_path = path
	var puzzle = Graph.load_from_xml(puzzle_path)
	canvas.puzzle = puzzle
	canvas.normalize_view(self.get_rect().size)
	enabled = true
	update()


func _on_Button_pressed():
	Gameplay.load_puzzle_path = puzzle_path
	get_tree().change_scene("res://main.tscn")


func _on_Button_mouse_entered():
	grandparent.move_child(parent, grandparent.get_child_count() - 1)
	parent.rect_scale = Vector2(1.2, 1.2)
	pass # Replace with function body.


func _on_Button_mouse_exited():
	parent.rect_scale = Vector2(1, 1)
	pass # Replace with function body.
