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
var wait_time: float = 0.01 # number of seconds inbetween digs for visualization

# weighting targets for dynamicly weighted turn direction preference
var up_target: float = 0.3
var down_target: float = 0.2
var left_target: float = 0.35
var right_target: float = 0.15
var target_weights: Array = []

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

onready var body: KinematicBody2D = $Body


func _ready() -> void:
	# Each digger gets fresh target weights
	target_weights = [up_target, down_target, left_target, right_target]

	randomize()
	rng.randomize()


func spawn(starting_position: Vector2, new_boundary: Rect2, new_map: TileMap) -> void:
	pass

func live() -> void:
	pass


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
		body.position += (direction * 32)
		
		self.steps_since_turn += 1
	else:
		# turn since we can't go there
		turn()

# Sets the Digger direction to a new random direction
func turn() -> void:
	var new_direction: Vector2
#	print("target direction weights: %s, %s, %s, %s" % [up_target, down_target, left_target, right_target])
	
	# These should add up to one
#	assert(up_target + down_target + left_target + right_target == 1.0)
	
	# TODO FIXME makesure weights don't go negative
	# TODO FEATURE make spawn more likely to havppen in middle of wall for more designed look
	# get a random float between 0 and 1, use our weightings to determine where to go
	var weight = randf()
	if weight < up_target:
		new_direction = Vector2.UP
		self.down_target -= 0.2 # we really don't want to turn the opposite direction
		self.up_target -= 0.1 # take some weight away from this direction
		self.left_target += 0.15
		self.right_target += 0.15
	elif weight < up_target + down_target:
		new_direction = Vector2.DOWN
		self.up_target -= 0.2
		self.down_target -= 0.1
		self.left_target += 0.15
		self.right_target += 0.15
	elif weight < up_target + down_target + left_target:
		new_direction = Vector2.LEFT
		self.right_target -= 0.2
		self.left_target -= 0.1
		self.up_target += 0.15
		self.down_target += 0.15
	elif weight < 10.0: # FIXME have some issues where weights add up to more than one. should be < 1.0
		new_direction = Vector2.RIGHT
		self.left_target -= 0.2
		self.right_target -= 0.1
		self.up_target += 0.15
		self.down_target += 0.15

#	print("target direction weights: %s, %s, %s, %s" % [up_target, down_target, left_target, right_target])
	self.direction = new_direction
	self.steps_since_turn = 0
