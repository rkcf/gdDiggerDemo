class_name RoomDigger
extends Digger


var max_room_size: int = 8
var min_room_size: int = 4
var room: Room2D


func live() -> void:
	var new_room: Room2D = create_room()
	self.room = new_room
	dig_room(new_room)
	destroy()

# Make a new randomly generated Room2D object
func create_room() -> Room2D:
	# Get a random width and height
	var width: int = round(rand_range(min_room_size, max_room_size))
	var height: int = round(rand_range(min_room_size, max_room_size))
	
	# TODO Fix this, make sure rooms are always positioned within the boundary
	print(position)
	assert(boundary.has_point(position))
	
	# We failed to randomly pick a point in space, so we are going to step down from the max size until we find one that works
	width = max_room_size
	while not boundary.has_point(Vector2(position.x + width, position.y)):
		width -= 1
		# abandon making the room if it is too small
		if width < 1:
			break
	
	height = max_room_size
	while not boundary.has_point(Vector2(position.x, position.y + height)):
		height -= 1
		# abandon making the room if it is too small
		if height < 1:
			break
	
	# Make sure width and height are within boundary
	assert(boundary.has_point(Vector2(position.x + width, position.y)))
	assert(boundary.has_point(Vector2(position.x, position.y + height)))
	
	# Create the size vector
	var size: Vector2 = Vector2(width, height)
	# Find the top left corner to store the position
	var new_room: Room2D = Room2D.new(position, size)
	return new_room


func destroy() -> void:
	print("RoomDigger Died")
	emit_signal("digger_died", self)


func dig_room(room: Room2D) -> void:
	print("Digging Room at %s" % self.position)
	for x in room.size.x:
		for y in room.size.y:
			var next_dig = room.position + Vector2(x, y)
			if self.boundary.has_point(next_dig):
				self.position = next_dig
				dig()
				yield(get_tree().create_timer(self.wait_time), "timeout")
