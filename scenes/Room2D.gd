class_name Room2D
extends Node


const DIRECTIONS = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

var position: Vector2 # upper left position of room
var size: Vector2 # (width, height) vector giving size of the room
var area: Rect2


func _init(position: Vector2, size: Vector2):
	randomize()
	self.position = position
	self.size = size
	self.area = Rect2(self.position, self.size)

# Returns a random position in global coordinates within the room
func random_position() -> Vector2:
	var x: int = round(rand_range(0, size.x - 1))
	var y: int = round(rand_range(0, size.y - 1))
	var rand_pos: Vector2 = position + Vector2(x, y)
	return rand_pos

# returns random border wall segment position
func random_wall() -> Vector2:
	var rand_side = DIRECTIONS[randi() % 4]
	var rand_segment: Vector2
	match rand_side:
		Vector2.UP: # Top side
			rand_segment.y = 0
			rand_segment.x = round(rand_range(0, size.x - 1))
		Vector2.DOWN: # Bottom side
			rand_segment.y = self.size.y - 1
			rand_segment.x = round(rand_range(0, size.x - 1))
		Vector2.LEFT: # Left side
			rand_segment.x = 0
			rand_segment.y = round(rand_range(0, size.y - 1))
		Vector2.RIGHT: # Right side
			rand_segment.x = self.size.x - 1
			rand_segment.y = round(rand_range(0, size.y - 1))
	var rand_wall_pos: Vector2 = position + rand_segment
	return rand_wall_pos
