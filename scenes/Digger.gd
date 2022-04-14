class_name Digger
extends Node


signal digger_died(digger)


const DIRECTIONS = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]


var position: Vector2 # Diggers current position
var direction: Vector2 # Diggers current direction
var directions = [] # Directions array for better rng selection
var dig_history: Array = [] # A list of positions the Digger has dug
var boundary: Rect2 # The limits of where the Digger can go
var steps_since_turn: int # number of steps since Digger last turned
var max_steps_to_turn: int = 2 # maximum number of steps until turn
var life_length: int = 300 # number of tiles to dig before destructing
var tile_map: TileMap
var wait_time: float = .01 # number of seconds inbetween digs for visualization


onready var body: KinematicBody2D = $Body

# Create a new Digger
func spawn(starting_position: Vector2, new_boundary: Rect2, new_map: TileMap) -> void:
	print("Spawning new Digger")

	randomize()
	directions = DIRECTIONS.duplicate()
	directions.shuffle()

	self.position = starting_position
	body.position = starting_position * 32
	self.boundary = new_boundary
	self.tile_map = new_map
	# get an initial direction facing
	turn()
	# Always dig out the starting tile
	dig()


# Main running loop fod Digger
func live() -> void:
	while life_length > 0:
		move()
		# See if we have already dug here
		if tile_map.get_cellv(self.position) != tile_map.INVALID_CELL:
			dig()
			yield(get_tree().create_timer(wait_time), "timeout")
		if steps_since_turn >= max_steps_to_turn:
			turn()
	destroy()

# Called on the death of a digger
func destroy() -> void:
	# spawn new room digger
	print("Digger Died")
	emit_signal("digger_died", self)

# dig out an area
func dig() -> void:
#	print("Digging at %s" % position)
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
		 # TODO fix not drawing movement
		body.position += (direction * 32)
		
		self.steps_since_turn += 1
	else:
		# turn since we can't go there
		turn()

# Sets the Digger direction to a new random direction
func turn() -> void:
	if directions.empty():
		directions = DIRECTIONS.duplicate()
		directions.shuffle()

# Take the direction out of the array to avvoid picking it multiple times
	var new_direction = directions.pop_front()

	self.direction = new_direction
	self.steps_since_turn = 0
