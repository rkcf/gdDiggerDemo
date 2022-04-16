class_name RoomDigger
extends Digger


signal room_dug


var max_room_size: int
var min_room_size: int
var similar_sized_rooms: bool # Whether we want our room sizes to be around the average room size
var room: Room2D = null
var job_complete: bool = false

# Create a new Digger
func spawn(new_room: Room2D, new_map: TileMap) -> void:
	print("Spawning new Room Digger")

	self.room = new_room
	body.position = new_room.position * 32
	self.tile_map = new_map
	
	self.max_room_size = Globals.digger_config["max_room_size"]
	self.min_room_size = Globals.digger_config["min_room_size"]
	self.similar_sized_rooms = Globals.digger_config["similar_sized_rooms"]
	
	# Room Diggers always dig down
	turn(Vector2.DOWN)
	# Always dig out the starting tile


func live():
	dig_room()
	yield(self, "room_dug")
#		print("Room Digger has no reason to live")


func dig_room():
	print("Digging Room at %s" % room.position)
	for x in room.size.x:
		for y in room.size.y:
			var next_dig: Vector2 = room.position + Vector2(x, y)

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
