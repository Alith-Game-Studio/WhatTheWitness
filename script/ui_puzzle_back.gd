extends TextureRect


func draw_background():
	texture = null
	var vport = Viewport.new()
	vport.size = self.rect_size * 3
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
	texture = image_texture
