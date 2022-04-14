class_name RoomDigger
extends Digger


var max_room_size: int = 10
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
	# Create the size vector
	var size: Vector2 = Vector2(width, height)
	# Find the top left corner to store the position
	var top_corner: Vector2 = (position - size/2).ceil()
	var new_room: Room2D = Room2D.new(top_corner, size)
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
