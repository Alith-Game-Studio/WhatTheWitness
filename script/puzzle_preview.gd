extends Node2D

var enabled = false
onready var frame = $PuzzlePreview
onready var visualizer = $PuzzlePreview/PuzzleVisualizer
onready var parent = $".."
onready var puzzle_credit_text = $"../../../SideMenu/PuzzleCredits"
onready var points_label = $PuzzlePreview/PointsLabel
onready var delete_bar = $PuzzlePreview/PointsLabel/ColorRect
var puzzle_name
var puzzle_unlocked
var linked_solution_texture : TextureRect
var points = 0
var masks 

func update_solution_texture():
	if (linked_solution_texture != null):
		var vport = Viewport.new()
		vport.size = Vector2(1024, 1024)
		vport.render_target_update_mode = Viewport.UPDATE_ALWAYS 
		vport.transparent_bg = true
		self.add_child(vport)
		var cvitem = Control.new()
		vport.add_child(cvitem)
		cvitem.rect_min_size = Vector2(1024, 1024)
		cvitem.name = puzzle_name.replace('.', '|')
		cvitem.set_script(load("res://script/puzzle_solution_renderer.gd"))
		yield(VisualServer, "frame_post_draw")
		var vport_img = vport.get_texture().get_data()
		vport_img.flip_y()
		remove_child(vport)
		vport.queue_free()
		var image_texture = ImageTexture.new()
		image_texture.create_from_image(vport_img)
		linked_solution_texture.texture = image_texture

	

func show_puzzle(load_puzzle_name, unlocked=true):
	puzzle_name = load_puzzle_name
	puzzle_unlocked = unlocked
	update_solution_texture()
	if (unlocked):
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
		yield(VisualServer, "frame_post_draw")
		var vport_img = vport.get_texture().get_data()
		vport_img.flip_y()
		# vport_img.save_png("res://img/render/%s.png" % cvitem.name.replace('|', '.'))
		remove_child(vport)
		# will the texture be freed?
		vport.queue_free()
		var image_texture = ImageTexture.new()
		image_texture.create_from_image(vport_img)
		visualizer.texture = image_texture
	points_label.bbcode_text = '[center]%s[/center]' % (
		'' if points == 0 else '1 pt' if points == 1 else '%d pts' % points
	)
	if (SaveData.puzzle_solved(puzzle_name) and points != 0):
		points_label.modulate = Color(1.0, 1.0, 1.0, 0.5)
		delete_bar.visible = true
	else:
		points_label.modulate = Color.white
		delete_bar.visible = false
		
func update_puzzle(unlocked=true):
	show_puzzle(puzzle_name, unlocked)

func _on_Button_pressed():
	if (puzzle_unlocked and test_mask()):
		_on_Button_mouse_exited()
		Gameplay.puzzle_name = puzzle_name
		Gameplay.playing_custom_puzzle = false
		$"/root/LevelMap/PuzzleUI".load_puzzle(Gameplay.PUZZLE_FOLDER + Gameplay.puzzle_name)
		$"/root/LevelMap/PuzzleUI".show()
		$"/root/LevelMap/Menu".hide()
		MenuData.can_drag_map = false
		puzzle_credit_text.bbcode_text = ''
	
func _on_Button_mouse_entered():
	if (puzzle_unlocked):
		parent.move_child(self, parent.get_child_count() - 2)
		frame.rect_scale = Vector2(1.2, 1.2)
		MenuData.can_drag_map = false
		puzzle_credit_text.bbcode_text = '[right] %s [/right]' % Credits.get_full_credit(puzzle_name)


func _on_Button_mouse_exited():
	frame.rect_scale = Vector2(1.0, 1.0)
	MenuData.can_drag_map = true
	puzzle_credit_text.bbcode_text = ''

func test_mask():
	if (masks == null):
		masks = $"/root/LevelMap/Menu/View/Masks".get_children()
	for mask in masks:
		var relative_pos : Vector2 = mask.get_local_mouse_position() / mask.rect_size
		if (relative_pos[0] >= 0 and relative_pos[0] < 1 and relative_pos[1] >= 0 and relative_pos[1] < 1):
			var image = mask.get_texture().get_data()
			image.lock()
			var image_pos = relative_pos * image.get_size()
			var pixel = image.get_pixel(floor(image_pos[0]), floor(image_pos[1]))
			if (pixel.r < 0.5):
				return false
	return true


func _on_Button_gui_input(event):
	if (event is InputEventMouseMotion and not event.is_pressed()):
		if (puzzle_unlocked and test_mask()):
			_on_Button_mouse_entered()
		else:
			_on_Button_mouse_exited()
			
