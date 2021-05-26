extends TextureRect

var enabled = false
var canvas = Visualizer.PuzzleCanvas.new()
onready var parent = get_node('..')
onready var grandparent = get_node('../..')
var puzzle_path
		
func show_puzzle(path, rendered_image):
	var image_texture = ImageTexture.new()
	image_texture.create_from_image(rendered_image)
	texture = image_texture
	puzzle_path = path
	var puzzle = Graph.load_from_xml(puzzle_path)
	canvas.puzzle = puzzle
	canvas.normalize_view(self.get_rect().size)


func _on_Button_pressed():
	_on_Button_mouse_exited()
	Gameplay.load_puzzle_path = puzzle_path
	$"/root/LevelMap/PuzzleUI".load_puzzle()
	$"/root/LevelMap/View".hide()
	$"/root/LevelMap/PuzzleUI".show()
	


func _on_Button_mouse_entered():
	grandparent.move_child(parent, grandparent.get_child_count() - 1)
	parent.rect_scale = Vector2(1.2, 1.2)
	pass # Replace with function body.


func _on_Button_mouse_exited():
	parent.rect_scale = Vector2(1, 1)
	pass # Replace with function body.
