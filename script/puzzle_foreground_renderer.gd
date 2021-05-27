extends Control

func _draw():
	if (Gameplay.background_texture != null):
		draw_texture(Gameplay.background_texture, Vector2(0, 0))
		if (Gameplay.canvas != null):
			Gameplay.canvas.draw_solution(self, Gameplay.solution, Gameplay.validator, Gameplay.validation_elasped_time)
			Gameplay.canvas.draw_validation(self, Gameplay.puzzle, Gameplay.validator, Gameplay.validation_elasped_time)
func draw_background():
	var vport = Viewport.new()
	vport.size = self.rect_size
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
	update()
