class_name RoomDigger
extends Digger


signal room_dug


var max_room_size: int
var min_room_size: int
var similar_sized_rooms: bool # Whether we want our room sizes to be around the average room size
var room: Room2D = null
var job_complete: bool = false

# Create a new Digger
func spawn(starting_position: Vector2, new_boundary: Rect2, new_map: TileMap) -> void:
	print("Spawning new Room Digger")

	self.position = starting_position
	body.position = starting_position * 32
	self.boundary = new_boundary
	self.tile_map = new_map
	
	self.max_room_size = Globals.digger_config["max_room_size"]
	self.min_room_size = Globals.digger_config["min_room_size"]
	self.similar_sized_rooms = Globals.digger_config["similar_sized_rooms"]
	
	# Room Diggers always dig down
	turn(Vector2.DOWN)
	# Always dig out the starting tile


func live():
	var new_room: Room2D = create_room()
	# Check to see if we have abandoned the building project due to out of bounds issues
	if new_room:
		print(new_room)
		self.room = new_room
		dig_room()
		if !job_complete:
			yield(self, "room_dug")
		else:
			emit_signal("completed")
#		print("Room Digger has no reason to live")
	else:
		print("abandoning room dig job")


func dig_room():
	print("Digging Room at %s" % self.position)
	for x in room.size.x:
		for y in room.size.y:
			var next_dig: Vector2 = room.position + Vector2(x, y)
			var next_next_dig: Vector2 = next_dig + Vector2.DOWN # we can see through walls to see if there is something built aready
			# TODO Prevent issue where we do not connect to corridor because of this check
			# TODO check if cell is room or corridor
			# TODO cbeck all directions instead of just down
#			if tile_map.get_cellv(next_next_dig) == -1:
#				break
			if self.boundary.has_point(next_dig):
				self.position = next_dig
				body.position = next_dig * 32
				dig()
				if Globals.ui_config["animate"]:
					yield(get_tree().create_timer(self.wait_time), "timeout")
	# set that we have completed our job
	print("room dig job completed")
	self.job_complete = true
	emit_signal("room_dug")


# Called on the death of a digger
func destroy() -> void:
	print("Destroying Room Digger")
	self.queue_free()

# Make a new randomly generated Room2D object
func create_room() -> Room2D:
	# Get a random width and height
	var width: int
	var height: int

	if similar_sized_rooms: # We use a normal curve SD=2 based around the average size for this
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
