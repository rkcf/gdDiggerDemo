class_name Room2D
extends Node


var position: Vector2 # upper left position of room
var size: Vector2 # (width, height) vector giving size of the room
var area: Rect2


func _init(position: Vector2, size: Vector2):
	self.position = position
	self.size = size
	self.area = Rect2(self.position, self.size)

# Returns a random position in global coordinates within the room
func random_position() -> Vector2:
	var x: int = round(rand_range(0, size.x - 1))
	var y: int = round(rand_range(0, size.y - 1))
	var rand_pos: Vector2 = position + Vector2(x, y)
	return rand_pos
