extends Viewport
var drawing_controls

func _ready():
	get_texture().flags = Texture.FLAG_FILTER
	drawing_controls = get_children()

func update_all():
	for child in drawing_controls:
		child.update()

func draw_background():
	var vport = Viewport.new()
	vport.size = self.size
	vport.render_target_update_mode = Viewport.UPDATE_ALWAYS 
	# vport.msaa = Viewport.MSAA_4X # useless for 2D
	self.add_child(vport)
	var cvitem = Control.new()
	vport.add_child(cvitem)
	cvitem.rect_min_size = vport.size
	cvitem.set_script(load("res://script/puzzle_background_renderer.gd"))
	yield(VisualServer, "frame_post_draw")
	var vport_img = vport.get_texture().get_data()
	vport_img.flip_y()
	remove_child(vport)
	vport.queue_free()
	var image_texture = ImageTexture.new()
	image_texture.create_from_image(vport_img)
	Gameplay.background_texture = image_texture
	update_all()
