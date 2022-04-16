class_name Room2D
extends Node


const DIRECTIONS = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

var position: Vector2 # upper left position of room
var size: Vector2 # (width, height) vector giving size of the room
var area: Rect2
var walls: Rect2

var rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _init(new_position: Vector2, new_size: Vector2):
	randomize()
	rng.randomize()
	self.position = new_position
	self.size = new_size
	self.area = Rect2(self.position, self.size)
	self.walls = Rect2(self.position.x - 1, self.position.y - 1, self.size.x +2, self.size.y + 2)
	
	# Draw a rectangle around the room if this option is enabled
	if Globals.ui_config["draw_walls"]:
		var rrect = ReferenceRect.new()
		rrect.editor_only = false
		rrect.rect_position = position * 32
		rrect.rect_size = size * 32
		add_child(rrect)

# Returns a random position in global coordinates within the room
func random_position() -> Vector2:
	var x: int = round(rand_range(0, size.x - 1))
	var y: int = round(rand_range(0, size.y - 1))
	var rand_pos: Vector2 = position + Vector2(x, y)
	return rand_pos

# returns a wall border position near the middle of the wall
func random_wall() -> Dictionary:
	var rand_side = DIRECTIONS[randi() % 4]
	var rand_segment: Vector2 = Vector2.ZERO
	match rand_side:
		Vector2.UP: # Top side
			rand_segment.y = 0
			rand_segment.x = rng.randfn(size.x / 2, 1)
		Vector2.DOWN: # Bottom side
			rand_segment.y = self.size.y - 1
			rand_segment.x = rng.randfn(size.x / 2, 1)
		Vector2.LEFT: # Left side
			rand_segment.x = 0
			rand_segment.y = rng.randfn(size.y / 2, 1)
		Vector2.RIGHT: # Right side
			rand_segment.x = self.size.x - 1
			rand_segment.y = rng.randfn(size.y / 2, 1)
	var rand_wall_pos: Vector2 = position + rand_segment
	return {"position": rand_wall_pos, "direction": rand_side}
