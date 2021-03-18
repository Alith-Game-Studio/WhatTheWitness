extends ColorRect

var enabled = false
var canvas = Visualizer.Canvas.new(self)
var puzzle_path
func _draw():
	if (!enabled):
		return
	canvas.draw_witness()
		
func show_puzzle(path):
	puzzle_path = path
	var puzzle = Graph.load_from_xml(puzzle_path)
	canvas.solution = Solution.SolutionLine.new()
	canvas.puzzle = puzzle
	canvas.normalize_view(self.get_rect().size)
	enabled = true
	update()


func _on_Button_pressed():
	Gameplay.load_puzzle_path = puzzle_path
	get_tree().change_scene("res://main.tscn")
