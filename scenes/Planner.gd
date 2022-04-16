extends Node
class_name Planner

var boundary

var rng = RandomNumberGenerator.new()
var rooms: Array


func _init(level_boundary: Rect2):
	self.rooms = Globals.rooms
	self.boundary = level_boundary


func _ready() -> void:
	rng.randomize()
	randomize()


func plot_room(position: Vector2) -> Room2D:
	# Get a random width and height
	var doorway: Vector2 = position
	var width: int
	var height: int
	var max_room_size: int = Globals.digger_config["max_room_size"]
	var min_room_size: int = Globals.digger_config["min_room_size"]
	
	# offset the room so we aren't always starting in top left
	var offset_position = position
	offset_position.x = round(position.x + rand_range(-2, 2))
	offset_position.y = round(position.y + rand_range(-2, 2))

	# Check to see if proposed room site is in bounds
	if !boundary.has_point(offset_position):
		# try original non offset position
		if !boundary.has_point(position):
			return null # we can't make a room here
			print("Planner is working in an out of bounds area!")
	else:
		print("Using offset position")
		position = offset_position

	if Globals.digger_config["similar_sized_rooms"]: # We use a normal curve SD=2 based around the average size for this
		var average_room_size = (max_room_size - min_room_size ) / 2
		width = round(rng.randfn(average_room_size, 1))
		height = round(rng.randfn(average_room_size, 1))
	else:
		width = round(rand_range(min_room_size, max_room_size))
		height = round(rand_range(min_room_size, max_room_size))

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


	# Check if room is still connected to corridor
	if new_room.walls.has_point(doorway):
		return new_room
	else:
		new_room.position = doorway # reset to the original position
		new_room.area = Rect2(doorway, size)
		return new_room


# Check whether the room building area is free of obstructions
func check_if_good_to_build(position: Vector2) -> bool:
	if Globals.digger_config["avoid_overlap"]:
		var buffer_size = Globals.digger_config["max_room_size"] # How big of an area do we want to look for rooms in
		# Shift the position of the buffer zone up and to the left so we have the occasional overlap
		var offset_x = position.x - buffer_size / 2
		var offset_y = position.y - buffer_size / 2
		var area = Rect2(Vector2(offset_x, offset_y), Vector2(buffer_size, buffer_size))
		for room in rooms:
			if area.intersects(room.area): # If the proposed building site intersects with a previously made room we don't build here
				return false
	return true
