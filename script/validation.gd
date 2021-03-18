extends Node

class Validator:
	
	var solution_validity: int # 0: unknown, 1: correct, -1: wrong
	var errors: Array
	
	func validate(puzzle, solution):
		solution.validity = -1
	
	func reset():
		pass
		
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
