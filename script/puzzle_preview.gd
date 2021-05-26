extends Node2D

var enabled = false
onready var frame = $PuzzlePreview
onready var visualizer = $PuzzlePreview/PuzzleVisualizer
onready var parent = $".."
var puzzle_name
		
func show_puzzle(load_puzzle_name):
	puzzle_name = load_puzzle_name
	var vport = Viewport.new()
	vport.size = Vector2(256, 256)
	vport.render_target_update_mode = Viewport.UPDATE_ALWAYS 
	# vport.msaa = Viewport.MSAA_4X # useless for 2D
	self.add_child(vport)
	var cvitem = Control.new()
	vport.add_child(cvitem)
	cvitem.rect_min_size = Vector2(256, 256)
	cvitem.name = puzzle_name.replace('.', '|')
	cvitem.set_script(load("res://script/puzzle_renderer.gd"))
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	var vport_img = vport.get_texture().get_data()
	vport_img.flip_y()
	# vport_img.save_png("res://img/render/%s.png" % cvitem.name.replace('|', '.'))
	remove_child(vport)
	# will the texture be freed?
	vport.queue_free()
	var image_texture = ImageTexture.new()
	image_texture.create_from_image(vport_img)
	visualizer.texture = image_texture
	
func update_puzzle():
	show_puzzle(puzzle_name)

func _on_Button_pressed():
	_on_Button_mouse_exited()
	Gameplay.puzzle_name = puzzle_name
	$"/root/LevelMap/PuzzleUI".load_puzzle()
	$"/root/LevelMap/PuzzleUI".show()
	$"/root/LevelMap/Menu".hide()
	


func _on_Button_mouse_entered():
	parent.move_child(self, parent.get_child_count() - 1)
	frame.rect_scale = Vector2(1.2, 1.2)
	pass # Replace with function body.


func _on_Button_mouse_exited():
	frame.rect_scale = Vector2(1.0, 1.0)
	pass # Replace with function body.
