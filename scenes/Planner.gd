extends Node
class_name Planner

var boundary

var rng = RandomNumberGenerator.new()


func _init(level_boundary: Rect2):
	self.boundary = level_boundary


func _ready() -> void:
	rng.randomize()
	randomize()


func plot_room(position: Vector2) -> Room2D:
	# Get a random width and height
	var width: int
	var height: int
	var max_room_size: int = Globals.digger_config["max_room_size"]
	var min_room_size: int = Globals.digger_config["min_room_size"]
	
	if Globals.digger_config["similar_sized_rooms"]: # We use a normal curve SD=2 based around the average size for this
		var average_room_size = (max_room_size - min_room_size ) / 2
		width = round(rng.randfn(average_room_size, 1))
		height = round(rng.randfn(average_room_size, 1))
	else:
		width = round(rand_range(min_room_size, max_room_size))
		height = round(rand_range(min_room_size, max_room_size))

	# TODO Fix this, make sure rooms are always positioned within the boundary
#	print(position)
	assert(boundary.has_point(position))
	
	# We failed to randomly pick a point in space, so we are going to step down from the max size until we find one that works
	width = max_room_size
	while not boundary.has_point(Vector2(position.x + width, position.y)):
		width -= 1
		# abandon making the room if it is too small
		if width < min_room_size:
			return null
	# find a new width in the narrower range
	width = round(rand_range(min_room_size, width))
	
	height = max_room_size
	while not boundary.has_point(Vector2(position.x, position.y + height)):
		height -= 1
		# abandon making the room if it is too small
		if height < min_room_size:
			return null

	height = round(rand_range(min_room_size, height - 1))
	# Make sure width and height are within boundary
	assert(boundary.has_point(Vector2(position.x + width, position.y)))
	assert(boundary.has_point(Vector2(position.x, position.y + height)))
#	print("size: %s, %s" % [width, height])
	# Create the size vector
	var size: Vector2 = Vector2(width, height)
	# Find the top left corner to store the position
	var new_room: Room2D = Room2D.new(position, size)
	return new_room
