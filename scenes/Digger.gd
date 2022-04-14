class_name Digger
extends Node


const DIRECTIONS = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]


var position: Vector2 # Diggers current position
var direction: Vector2 # Diggers current direction
var dig_history: Array = [] # A list of positions the Digger has dug
var boundary: Rect2 # The limits of where the Digger can go
var steps_since_turn: int # number of steps since Digger last turned
var max_steps_to_turn: int # maximum number of steps until turn
var life_length: int = 500 # number of tiles to dig before destructing
var tile_map: TileMap

# Create a new Digger
func spawn(starting_position: Vector2, new_boundary: Rect2, new_map: TileMap) -> void:
	randomize()
	print("Spawning new Digger")
	self.position = starting_position
	self.boundary = new_boundary
	self.tile_map = new_map
	# get an initial direction facing
	turn()
	# Always dig out the starting tile
	dig()
	live()

# Main running loop fod Digger
func live() -> void:
	while life_length > 0:
		move()
		# See if we have already dug here
		if tile_map.get_cellv(self.position) != tile_map.INVALID_CELL:
			dig()
		if steps_since_turn >= max_steps_to_turn:
			turn()
	destroy()

# Get rid of a Digger
func destroy() -> void:
	print("Destroying Digger")
	queue_free()

# dig out an area
func dig() -> void:
	print("Digging at %s" % position)
	dig_history.append(position)
	# Erase the current tile
	tile_map.set_cellv(self.position, -1)
	life_length -= 1
	

# try and move to the next position
func move() -> void:
	var target_position: Vector2 = position + direction
	# Check that the target is inside our border
	if boundary.has_point(target_position):
		self.position = target_position
		self.steps_since_turn += 1
	else:
		# turn since we can't go there
		turn()

# Sets the Digger direction to a new random direction
func turn() -> void:
	var new_direction = DIRECTIONS[randi() % 4]
	# Make sure we don't pick the same direction twice
	while new_direction == self.direction:
		new_direction = DIRECTIONS[randi() % 4]
	print("Digger turning %s" % new_direction)
	self.direction = new_direction
	self.steps_since_turn = 0
