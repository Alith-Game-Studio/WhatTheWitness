extends TextureRect
var cvitem = $Viewport/Control
var vport = $Viewport

func update_foreground():
	if (cvitem != null):
		cvitem.update()

func draw_foreground():
	self.add_child(vport)
	cvitem = Control.new()
	vport.add_child(cvitem)
	cvitem.rect_min_size = vport.size
	cvitem.set_script(load("res://script/puzzle_foreground_renderer.gd"))
	yield(VisualServer, "frame_post_draw")
	texture = vport.get_texture()
	texture.flags = Texture.FLAG_FILTER
	print(texture.flags)
	print(texture.get_size())
